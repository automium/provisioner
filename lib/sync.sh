#!/bin/bash

set -e
set -o pipefail

source lib/helpers.sh

# Clean up old interrupted tasks
curl -f -sS -X DELETE "http://${CONSUL}:${CONSUL_PORT}/v1/kv/${CLUSTER_NAME}/cleanup?recurse=yes" > /dev/null

source lib/plan.sh

DESTROY_NUMBERS=$(get_destroy_nodes)
for DESTROY_NUMBER in $DESTROY_NUMBERS; do
  curl -sS -X PUT http://${CONSUL}:${CONSUL_PORT}/v1/kv/${CLUSTER_NAME}/cleanup/${IDENTITY}-${DESTROY_NUMBER} -d "{ \"name\": \"${IDENTITY}-${DESTROY_NUMBER}\" }" > /dev/null
  echo "$(date +%x\ %H:%M:%S) [START] Destroy instance ${IDENTITY}-${DESTROY_NUMBER}"

  if [ "${PROVISIONER_CONFIG_WAIT_CLEANUP}" == "true" ]; then
    TIMEOUT=30
    COUNT=0
    echo "$(date +%x\ %H:%M:%S) [START] Cleanup tasks on node ${IDENTITY}-${DESTROY_NUMBER}"
    while [ "$(curl -sS http://${CONSUL}:${CONSUL_PORT}/v1/kv/${CLUSTER_NAME}/cleanup/${IDENTITY}-${DESTROY_NUMBER})" ]; do
      echo "$(date +%x\ %H:%M:%S) Wait until all cleanup tasks finish on node ${IDENTITY}-${DESTROY_NUMBER}"
      if [ ${COUNT} -ge ${TIMEOUT} ]; then
        echo "$(date +%x\ %H:%M:%S) Timeout reached for cleanup tasks on node ${IDENTITY}-${DESTROY_NUMBER}"
        break
      fi;
      COUNT=$(echo ${COUNT} + 1 | bc)
      sleep 1
    done
    echo "$(date +%x\ %H:%M:%S) [END] Cleanup tasks on node ${IDENTITY}-${DESTROY_NUMBER}"
  fi
done

CREATE_NUMBERS=$(get_create_nodes)
for CREATE_NUMBER in $CREATE_NUMBERS; do
  echo "$(date +%x\ %H:%M:%S) [START] Create instance ${IDENTITY}-${CREATE_NUMBER}"
done

source lib/apply.sh

for DESTROY_NUMBER in $DESTROY_NUMBERS; do
  # Clean up removing task
  curl -f -sS -X DELETE http://${CONSUL}:${CONSUL_PORT}/v1/kv/${CLUSTER_NAME}/cleanup/${IDENTITY}-${DESTROY_NUMBER} > /dev/null
  echo "$(date +%x\ %H:%M:%S) [END] Destroy instance ${IDENTITY}-${DESTROY_NUMBER}"
done

for CREATE_NUMBER in $CREATE_NUMBERS; do
  echo "$(date +%x\ %H:%M:%S) [START] Wait instance ${IDENTITY}-${CREATE_NUMBER}"
  wait_health_ok ${IDENTITY}-${CREATE_NUMBER}
  echo "$(date +%x\ %H:%M:%S) [END] Wait instance ${IDENTITY}-${CREATE_NUMBER}"
  echo "$(date +%x\ %H:%M:%S) [END] Create instance ${IDENTITY}-${CREATE_NUMBER}"
done
