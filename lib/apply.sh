#!/bin/bash

source lib/init.sh

terraform plan -out=plan.tfplan providers/$PROVIDER
terraform apply -auto-approve plan.tfplan
