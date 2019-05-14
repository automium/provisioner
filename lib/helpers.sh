#!/bin/bash

get_current_quantity() {
  set -e
  cd providers/$PROVIDER >/dev/null
  [ -L .terraform ] || ln -s ../../.terraform . >/dev/null
  terraform state list | grep openstack_compute_instance_v2 | wc -l
  cd ../.. >/dev/null
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

# Get the id of the instance
if [ "$CLUSTER_NAME" ]; then
  export IDENTITY=${CLUSTER_NAME}-${NAME}
else
  export IDENTITY=${NAME}
fi
