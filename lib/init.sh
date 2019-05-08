#!/bin/bash

envsubst < config.tf.tmpl > config.tf

if [ "$DEBUG" == "true" ]; then
  cat config.tf
fi

if [ "$CLUSTER_NAME" ]; then
  export IDENTITY=${CLUSTER_NAME}-${NAME}
else
  export IDENTITY=${NAME}
fi

CONTAINERS="$(swift --os-auth-url $OS_AUTH_URL --os-tenant-name $OS_TENANT_NAME --os-username $OS_USERNAME --os-password $OS_PASSWORD list)"
CONTAINER_EXIST=false
for CONTAINER in $CONTAINERS; do
  if [ "$CONTAINER" == "${PROVIDER}-${IDENTITY}" ]; then
    CONTAINER_EXIST=true
  fi;
done

if [ $CONTAINER_EXIST == "false" ]; then
  swift --os-auth-url https://api.entercloudsuite.com/v2.0 --os-tenant-name $OS_TENANT_NAME --os-username $OS_USERNAME --os-password $OS_PASSWORD post ${PROVIDER}-${IDENTITY}
fi

echo "[INFO] Configuration container: ${PROVIDER}-${IDENTITY}/terraform_state"
terraform init \
  -backend-config="container=${PROVIDER}-${IDENTITY}/terraform_state" \
  -backend-config="tenant_name=$OS_TENANT_NAME" \
  -backend-config="user_name=$OS_USERNAME" \
  -backend-config="password=$OS_PASSWORD" \
  -backend-config="region_name=$OS_REGION_NAME" \
  providers/$PROVIDER
