#!/bin/bash

# If apply.sh is called directly
if [ -z "$QUANTITY_CURRENT" ]; then
  QUANTITY_CURRENT=$QUANTITY
  export QUANTITY_CURRENT
  source lib/helpers.sh
  source lib/init.sh
fi

[ -f plan.tfplan ] || source lib/plan.sh
terraform apply -auto-approve plan.tfplan
rm plan.tfplan
