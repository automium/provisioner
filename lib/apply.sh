#!/bin/bash

# If apply.sh is called directly
if [ -z "$QUANTITY_CURRENT" ]; then
  QUANTITY_CURRENT=$QUANTITY
  export QUANTITY_CURRENT
fi

source lib/init.sh

terraform plan -out=plan.tfplan providers/$PROVIDER
terraform apply -auto-approve plan.tfplan
