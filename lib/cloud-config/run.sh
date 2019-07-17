#!/bin/bash

# Define all config.tf vars as bash vars
eval $(
cat << EOC | json2hcl -reverse | jq -r '.variable[] | keys[] as $k | "export \($k)=\(.[$k][].default)"'
${config}
EOC
)

# Save all config.tf vars as a json for ansible extra vars
config_json=\{$(cat << EOJ | json2hcl -reverse | jq '.variable[] | keys[] as $k | "\($k)\":\"\(.[$k][].default)"' | while read i; do echo -n $i,; done | sed 's/,$//g'
${config}
EOJ
)\}
export config_json

if [ "$cluster_name" ]; then
  identity=$${cluster_name}-$${name}
  export identity
else
  identity=$${name}
  export identity
fi

number=${number}
export number

# Define which service version use
if [ ! "$provisioner_role_version" ]; then
  provisioner_role_version=$${image}
  export provisioner_role_version
  config_json=$(echo -n $${config_json} | jq -c ".provisioner_role_version = \"$${image}\"")
  export config_json
fi

# Setup ansible role provisioner requirement
cd /usr/src/cloud
cat << EOG > provisioner_requirement.yml
- src: git+https://github.com/automium/ansible-provisioner.git
  version: master
  name: provisioner
EOG

run_bootstrap() {
  # Get bootstrap node
  consul_path=$${1}
  export consul_path
  ssh_keys_enabled=$${2}
  export ssh_keys_enabled
  provisioner_role_enabled=$${3}
  export provisioner_role_enabled
  bootstrap_session=$(curl -s -X PUT "http://$${consul}:$${consul_port}/v1/session/create" | jq .ID | sed 's/"//g')
  export bootstrap_session
  bootstrap=$(curl -s -X PUT --data "{ \"name\": \"$${identity}-$${number}\" }" "http://$${consul}:$${consul_port}/v1/kv/$${consul_path}/custom_bootstrap?acquire=$${bootstrap_session}")
  export bootstrap

  if [ "$bootstrap" == "true" ]; then
    echo "im the bootstrap node for $${consul_path}"
  fi

  # Run main playbook
  COMPLETED=false
  export COMPLETED
  while [ "$COMPLETED" == "false" ]; do
    (
      set -e
      set -o pipefail
      cd /usr/src/cloud
      source venv/bin/activate
      HOME=/root
      export HOME
      ansible-galaxy install -r provisioner_requirement.yml
      if [ $bootstrap == "true" ]; then
        ansible-playbook -e ansible_python_interpreter=/usr/bin/python --connection=local playbook.yml --skip-tags others --extra-vars="$${config_json}" | logger -s -n automium-agent.node.automium.consul -P 30514
      else
        ansible-playbook -e ansible_python_interpreter=/usr/bin/python --connection=local playbook.yml --skip-tags bootstrap --extra-vars="$${config_json}" | logger -s -n automium-agent.node.automium.consul -P 30514
      fi
    ) >> /var/log/cloud-scripts.log 2>&1
    if [ $? == 0 ]; then
      COMPLETED=true
    fi
    sleep 1
  done
}

# Prepare the cluster, with ssh key deploy and without run ansible role
run_bootstrap $${cluster_name} true false
# Prepare the group $${identity}}, without ssh key deploy and run ansible role
run_bootstrap $${cluster_name}/$${identity} false true
