#!/bin/bash

set -x

echo deregister node from consul
curl -sS -X PUT "http://${consul}:${consul_port}/v1/agent/force-leave/${name}-$${_NUMBER}"
curl -sS -X PUT "http://${consul}:${consul_port}/v1/catalog/deregister?dc=${consul_datacenter}" --data \{\"Datacenter\":\"${consul_datacenter}\",\"Node\":\"${name}-$${_NUMBER}\"\} > /dev/null

if [ ${quantity} == 0 ]; then
  echo "is the last node so clean up everything"
  # remove consul keys
  curl -sS -X DELETE "http://${consul}:${consul_port}/v1/kv/kubernetes/${name}?recurse=yes"
fi

exit 0
