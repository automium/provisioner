# Kubernetes

define playbook for distributed infrastracture using terraform, consul and ansible

ootb function:
- ssh keys spread before deploy
- bootstrap node election

requirements:
- consul
- terraform
- a prepared image that accept cloud init data
- jq
- json2hcl

## example

clone this project

```
git clone https://github.com/automium/kubernetes
cd kubernetes
```

copy config.tf.example to config.tf and edit it
```
cp config.tf.example config.tf
```

write your playbooks inside `src` folder for tasks that should run on all nodes (es src/50-main.yml)  
the order of execution of the playbooks inside `src` are alphabetical  
use tag with `bootstrap` label for task that must run one time on the leader (bootstrap) node  
use tag with `others` label for task that must not run on leader node  
access to the config.tf variables using `"{{ lookup('env','variable_x') }}"`
```
- name: this task runs only on the bootstrap node
  package: name="{{ item }}"
  with_items:
    - "{{ lookup('env','package_for_bootstrap_node') }}"
    - haproxy
  tags:
    - bootstrap
- name: this task runs on all nodes in parallel
  package: name=haproxy
- name: this task runs only on other nodes (except for bootstrap node) in parallel
  package: name=haproxy
  tags:
    - others
```

then deploy it
```
terraform init providers/openstack
terraform apply providers/openstack
```

## troubleshoot

export config values
```
eval $(cat config.tf | json2hcl -reverse | jq -r '.variable[] | keys[] as $k | "export \($k)=\(.[$k][].default)"')
```
and test the playbook
```
ansible-playbook src/50-main.yml
```
