#!/bin/bash

traperr() {
  echo "$(date +%x\ %H:%M:%S) [ERROR] Unexpected error, ${BASH_SOURCE[1]} at line ${BASH_LINENO[0]}"
}

trap traperr ERR

# Enable sentry log
if [ "${SENTRY_DSN}" ]; then
  eval "$(sentry-cli bash-hook | sed 's/: > "\$_SENTRY_LOG_FILE"//g' | sed 's/export SENTRY_LAST_EVENT/: > "\$_SENTRY_LOG_FILE"\n  export SENTRY_LAST_EVENT/g')"
fi

if [ "$PROVIDER" == "openstack" ]; then
  INSTANCE_ALIAS=openstack_compute_instance_v2
elif [ "$PROVIDER" == "vsphere" ]; then
  INSTANCE_ALIAS=vsphere_virtual_machine.instance
else
  >&2 echo "$(date +%x\ %H:%M:%S) No provider configured"
  false
fi

get_current_quantity() {
  set -e
  set -o pipefail


  cd providers/$PROVIDER > /dev/null
  [ -L .terraform ] || ln -s ../../.terraform . > /dev/null
  # Is the first deploy
  if [ "$CONTAINER_EXIST" == "false" ]; then
    echo 0
  else
    terraform state list | { grep ${INSTANCE_ALIAS} || test $? = 1; } | wc -l
  fi
  cd ../.. > /dev/null
}

get_health_issues() {
  set -e
  set -o pipefail

  OUTPUT=$(curl -Ss ${CONSUL}:${CONSUL_PORT}/v1/health/node/${1})
  if [ -z "$OUTPUT" ]; then
    echo get_health_issues: no check found
  fi
  CHECK_NUMBER=$(echo $OUTPUT | jq length)
  if [ $CHECK_NUMBER -lt 2 ]; then
    echo get_health_issues: need a minimum of 2 checks
  fi
  echo $OUTPUT | jq ".[] | select(.Status!=\"passing\")"
}

get_destroy_nodes() {
  set -e
  set -o pipefail

  DESTROY_NODES=$(tfjson plan.tfplan | jq -r ".instance // empty | with_entries(select(.key|contains(\"${INSTANCE_ALIAS}\"))) | to_entries[] | select(.value.destroy==true) | .key" )

  if [ -z "$( echo $DESTROY_NODES )" ]; then
    return
  fi
  if [ -z "$( echo $DESTROY_NODES | cut -d . -f 3 )" ]; then
    echo 0
  else
    for n in $DESTROY_NODES; do
      DESTROY_NODE=$(echo $n | cut -d . -f 3)
      [ -z "${DESTROY_NODE}" ] && echo 0 && continue
      echo $DESTROY_NODE
    done
  fi
}

get_create_nodes() {
  set -e
  set -o pipefail

  CREATE_NODES=$(tfjson plan.tfplan | jq -r ".instance // empty | with_entries(select(.key|contains(\"${INSTANCE_ALIAS}\"))) | to_entries[] | select(.value.destroy==false or .value.destroy_tainted==true) | .key" )

  if [ -z "$( echo $CREATE_NODES )" ]; then
    return
  fi
  if [ -z "$( echo $CREATE_NODES | cut -d . -f 3 )" ]; then
    echo 0
  else
    for n in $CREATE_NODES; do
      CREATE_NODE=$(echo $n | cut -d . -f 3)
      [ -z "${CREATE_NODE}" ] && echo 0 && continue
      echo $CREATE_NODE
    done
  fi
}

wait_health_ok() {
  set -e
  set -o pipefail

  while [ "$(get_health_issues $1)" ]; do
    echo "$(date +%x\ %H:%M:%S) Wait until all Consul's checks are fine on node $1"
    sleep 10
  done
}

taint_node() {
  set -e
  set -o pipefail

  NUMBER=$1
  # Workaround: cd into the providers directory to see state items
  cd providers/$PROVIDER
  [ -L .terraform ] || ln -s ../../.terraform . > /dev/null
  # Taint resource in instance $NUMBER
  terraform state list | grep "\[${NUMBER}\]" | grep module.instance | while read item; do
    RESOURCE=$(echo $item | sed 's/module\.instance\.//'| sed "s/\[${NUMBER}\]//")
    terraform taint -module=instance $RESOURCE.$NUMBER
  done
  cd ../..
}

untaint_node() {
  set -e
  set -o pipefail

  NUMBER=$1
  # Workaround: cd into the providers directory to see state items
  cd providers/$PROVIDER
  [ -L .terraform ] || ln -s ../../.terraform . > /dev/null
  # Taint resource in instance $NUMBER
  terraform state list | grep "\[${NUMBER}\]" | grep module.instance | while read item; do
    RESOURCE=$(echo $item | sed 's/module\.instance\.//'| sed "s/\[${NUMBER}\]//")
    terraform untaint -module=instance $RESOURCE.$NUMBER
  done
  cd ../..
}

untaint_nodes() {
  set -e
  set -o pipefail

  for n in $(seq 1 $(get_current_quantity)); do
    NUMBER=$(echo "$n - 1" | bc)
    untaint_node $NUMBER
  done
}
