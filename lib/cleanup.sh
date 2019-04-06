#!/bin/bash

set -x

# Define all config file as bash vars
eval $(
cat << EOC | json2hcl -reverse | jq -r '.variable[] | keys[] as $k | "export \($k)=\(.[$k][].default)"'
${config}
EOC
)

if [ "$cluster_name" ]; then
  export identity=$${cluster_name}-$${name}
else
  export identity=$${name}
fi

node_exist() {
  curl -s "http://$${consul}:$${consul_port}/v1/agent/members" | jq ".[] | select(.Name==\"$${name}-$${_NUMBER}\") | select(.Status!=3)"
}

while [ "$(node_exist)" ]; do
  echo deregister node from consul
  curl -sS -X PUT "http://$${consul}:$${consul_port}/v1/agent/force-leave/$${name}-$${_NUMBER}"
  curl -sS -X PUT "http://$${consul}:$${consul_port}/v1/catalog/deregister?dc=$${consul_datacenter}" --data \{\"Datacenter\":\"$${consul_datacenter}\",\"Node\":\"$${identity}-$${_NUMBER}\"\} > /dev/null
  sleep 1
done

if [ "$quantity" = "0" ]; then
  echo "is the last node so clean up everything"
  # remove consul keys
  curl -sS -X DELETE "http://$${consul}:$${consul_port}/v1/kv/$${cluster_name}/$${identity}?recurse=yes"
fi

exit 0
