#!/bin/bash

get_current_quantity() {
  curl -Ss ${CONSUL}:${CONSUL_PORT}/v1/agent/members | jq ".[] | select(.Name | contains(\"${IDENTITY}-\")) and select(.Status!=3)" | wc -l
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
    echo "Wait until there is no issue in the spawned node"
    sleep 10
  done
}

# Get the id of the instance
if [ "$CLUSTER_NAME" ]; then
  export IDENTITY=${CLUSTER_NAME}-${NAME}
else
  export IDENTITY=${NAME}
fi
