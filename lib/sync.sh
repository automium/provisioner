#!/bin/bash

source lib/helpers.sh

# Clean up old interrupted tasks
curl -f -sS -X DELETE "http://${CONSUL}:${CONSUL_PORT}/v1/kv/${CLUSTER_NAME}/${IDENTITY}/cleanup?recurse=yes" > /dev/null

source lib/plan.sh

DESTROY_NUMBERS=$(tfjson plan.tfplan | jq -r ".instance // empty | with_entries(select(.key|contains(\"openstack_compute_instance_v2.cluster\"))) | to_entries[] | select(.value.destroy==true) | .value.name" | sed "s/$IDENTITY-//" )
for DESTROY_NUMBER in $DESTROY_NUMBERS; do
  curl -sS -X PUT http://${CONSUL}:${CONSUL_PORT}/v1/kv/${CLUSTER_NAME}/${IDENTITY}/cleanup/${IDENTITY}-${DESTROY_NUMBER} > /dev/null
  echo "$(date +%x\ %H:%M:%S) [START] Destroy instance ${IDENTITY}-${DESTROY_NUMBER}"
done

CREATE_NUMBERS=$(tfjson plan.tfplan | jq -r ".instance // empty | with_entries(select(.key|contains(\"openstack_compute_instance_v2.cluster\"))) | to_entries[] | select(.value.destroy==false or .value.destroy_tainted==true) | .value.name" | sed "s/$IDENTITY-//" )
for CREATE_NUMBER in $CREATE_NUMBERS; do
  echo "$(date +%x\ %H:%M:%S) [START] Create instance ${IDENTITY}-${CREATE_NUMBER}"
done

source lib/apply.sh

for DESTROY_NUMBER in $DESTROY_NUMBERS; do
  # Clean up removing task
  curl -f -sS -X DELETE http://${CONSUL}:${CONSUL_PORT}/v1/kv/${CLUSTER_NAME}/${IDENTITY}/cleanup/${IDENTITY}-${DESTROY_NUMBER} > /dev/null
  echo "$(date +%x\ %H:%M:%S) [END] Destroy instance ${IDENTITY}-${DESTROY_NUMBER}"
done

for CREATE_NUMBER in $CREATE_NUMBERS; do
  echo "$(date +%x\ %H:%M:%S) [START] Wait instance ${IDENTITY}-${CREATE_NUMBER}"
  wait_health_ok ${IDENTITY}-${CREATE_NUMBER}
  echo "$(date +%x\ %H:%M:%S) [END] Wait instance ${IDENTITY}-${CREATE_NUMBER}"
  echo "$(date +%x\ %H:%M:%S) [END] Create instance ${IDENTITY}-${CREATE_NUMBER}"
done
