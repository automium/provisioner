#!/bin/bash

envsubst < config.tf.tmpl > config.tf

if [ "$DEBUG" == "true" ]; then
  cat config.tf
fi

CONTAINERS="$(swift --os-auth-url $OS_AUTH_URL --os-tenant-name $OS_TENANT_NAME --os-username $OS_USERNAME --os-password $OS_PASSWORD list)"
if [ -z "$(echo $CONTAINERS | grep ${PROVIDER}-${NAME})" ]; then
  swift --os-auth-url https://api.entercloudsuite.com/v2.0 --os-tenant-name $OS_TENANT_NAME --os-username $OS_USERNAME --os-password $OS_PASSWORD post ${PROVIDER}-${NAME}
fi

echo "[INFO] Configuration container: ${PROVIDER}-${NAME}/terraform_state"
terraform init \
  -backend-config="container=${PROVIDER}-${NAME}/terraform_state" \
  -backend-config="tenant_name=$OS_TENANT_NAME" \
  -backend-config="user_name=$OS_USERNAME" \
  -backend-config="password=$OS_PASSWORD" \
  -backend-config="region_name=$OS_REGION_NAME" \
  providers/$PROVIDER
