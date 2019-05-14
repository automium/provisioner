#!/bin/bash

# Define all config.tf vars as bash vars
eval $(
cat << EOC | json2hcl -reverse | jq -r '.variable[] | keys[] as $k | "export \($k)=\(.[$k][].default)"'
${config}
EOC
)

# Save all config.tf vars as a json for ansible extra vars
export config_json=\{$(cat << EOJ | json2hcl -reverse | jq '.variable[] | keys[] as $k | "\($k)\":\"\(.[$k][].default)"' | while read i; do echo -n $i,; done | sed 's/,$//g'
${config}
EOJ
)\}

if [ "$cluster_name" ]; then
  export identity=$${cluster_name}-$${name}
else
  export identity=$${name}
fi

export number=${number}

# Setup ansible role provisioner requirement
cd /usr/src/cloud
cat << EOG > provisioner_requirement.yml
- src: git+https://github.com/automium/ansible-provisioner.git
  version: master
  name: provisioner
EOG

run_bootstrap() {
  # Get bootstrap node
  export consul_path=$${1}
  export ssh_keys_enabled=$${2}
  export provisioner_role_enabled=$${3}
  export bootstrap_session=$(curl -s -X PUT "http://$${consul}:$${consul_port}/v1/session/create" | jq .ID | sed 's/"//g')
  export bootstrap=$(curl -s -X PUT --data "{ name: $${identity}-$${number}.node.$${consul_datacenter}.consul }" "http://$${consul}:$${consul_port}/v1/kv/$${consul_path}/custom_bootstrap?acquire=$${bootstrap_session}")

  if [ "$bootstrap" == "true" ]; then
      echo "im the bootstrap node for $${consul_path}"
  fi

  # Run main playbook
  export COMPLETED=false
  while [ "$COMPLETED" == "false" ]; do
    (
      cd /usr/src/cloud
      source venv/bin/activate
      export HOME=/root
      ansible-galaxy install -r provisioner_requirement.yml
      if [ $bootstrap == "true" ]; then
        ansible-playbook -e ansible_python_interpreter=/usr/bin/python --connection=local playbook.yml --skip-tags others --extra-vars=$${config_json} | logger -s -n automium-agent.node.automium.consul -P 30514
      else
        ansible-playbook -e ansible_python_interpreter=/usr/bin/python --connection=local playbook.yml --skip-tags bootstrap --extra-vars=$${config_json} | logger -s -n automium-agent.node.automium.consul -P 30514
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
