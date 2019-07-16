#!/bin/bash

set -e
set -o pipefail

# If destroy.sh is called directly
if [ -z "$QUANTITY_CURRENT" ]; then
  QUANTITY_CURRENT=$QUANTITY
  export QUANTITY_CURRENT
  source lib/init.sh
fi

terraform destroy -auto-approve providers/$PROVIDER
