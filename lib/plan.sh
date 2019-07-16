#!/bin/bash

set -e
set -o pipefail

# If apply.sh is called directly
if [ -z "$QUANTITY_CURRENT" ]; then
  QUANTITY_CURRENT=$QUANTITY
  export QUANTITY_CURRENT
  source lib/helpers.sh
  source lib/init.sh
fi

envsubst < config.tf.tmpl > config.tf

terraform plan -out=plan.tfplan providers/$PROVIDER
