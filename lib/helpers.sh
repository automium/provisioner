#!/bin/bash

get_current_quantity() {
  cd providers/$PROVIDER > /dev/null
  [ -L .terraform ] || ln -s ../../.terraform . > /dev/null
  terraform state list | grep openstack_compute_instance_v2 | wc -l
  cd ../.. > /dev/null
}

get_health_issues() {
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

wait_health_ok() {
  while [ "$(get_health_issues $1)" ]; do
    echo "$(date +%x\ %H:%M:%S) Wait until all Consul's checks are fine on node $1"
    sleep 10
  done
}

taint_node() {
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
  for n in $(seq 1 $(get_current_quantity)); do
    NUMBER=$(echo "$n - 1" | bc)
    untaint_node $NUMBER
  done
}

# Get the id of the instance
if [ "$CLUSTER_NAME" ]; then
  export IDENTITY=${CLUSTER_NAME}-${NAME}
else
  export IDENTITY=${NAME}
fi
