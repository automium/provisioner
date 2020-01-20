#!/bin/bash

set -e
set -o pipefail

# Get the id of the instance
if [ "$CLUSTER_NAME" ]; then
  IDENTITY=${CLUSTER_NAME}-${NAME}
  export IDENTITY
else
  IDENTITY=${NAME}
  export IDENTITY
fi

echo "$(date +%x\ %H:%M:%S) Check if consul is available or exit"
curl -sSf "http://${CONSUL}:${CONSUL_PORT}/v1/health/service/consul?passing" > /dev/null

j2 config.tf.tmpl > config.tf
j2 lib/state.tf.tmpl > lib/state.tf
TEMPLATES=$(find providers -name "*.tmpl")
for TEMPLATE in $TEMPLATES; do
  j2 $TEMPLATE > "${TEMPLATE//.tmpl/}"
done

if [ "$DEBUG" == "true" ]; then
  cat config.tf
fi

CONTAINERS="$(swift --os-auth-url $OS_AUTH_URL --os-tenant-name $OS_TENANT_NAME --os-username $OS_USERNAME --os-password $OS_PASSWORD list)"
CONTAINER_EXIST=false
export CONTAINER_EXIST
for CONTAINER in $CONTAINERS; do
  if [ "$CONTAINER" == "${PROVIDER}-${IDENTITY}" ]; then
    CONTAINER_EXIST=true
  fi;
done

if [ $CONTAINER_EXIST == "false" ]; then
  if [ "$QUANTITY" == "0" ]; then
    echo "$(date +%x\ %H:%M:%S) [EXIT] Quantity is 0, nothing to do"
    exit 0
  fi
  swift --os-auth-url $OS_AUTH_URL --os-tenant-name $OS_TENANT_NAME --os-username $OS_USERNAME --os-password $OS_PASSWORD post ${PROVIDER}-${IDENTITY} > /dev/null
fi

echo "$(date +%x\ %H:%M:%S) [INFO] Configuration container: ${PROVIDER}-${IDENTITY}/terraform_state"
[ -d .terraform ] || terraform init \
  -backend-config="container=${PROVIDER}-${IDENTITY}/terraform_state" \
  -backend-config="tenant_name=$OS_TENANT_NAME" \
  -backend-config="user_name=$OS_USERNAME" \
  -backend-config="password=$OS_PASSWORD" \
  -backend-config="region_name=$OS_REGION_NAME" \
  providers/$PROVIDER
