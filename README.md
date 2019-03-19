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

edit main.yml for tasks that should run on all nodes  
use tag with `bootstrap` label for task that must run one time on the leader (bootstrap) node  
use tag with `others` label for task that must not run on leader node  
access to the config.tf variables using `"{{ lookup('env','variable_x') }}"`
```
- name: this is task runs only on the bootstrap node
  package: name="{{ item }}"
  with_items:
    - "{{ lookup('env','package_for_bootstrap_node') }}"
    - haproxy
  tags:
    - bootstrap
- name: this is task runs on all nodes in parallel
  package: name=haproxy
- name: this is task runs only on other nodes (except bootstrap node) in parallel
  package: name=haproxy
  tags:
    - others
```

then deploy it
```
terraform init providers/openstack
terraform apply providers/openstack
```
