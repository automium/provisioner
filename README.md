# Provisioner

deploy ansible role in a distribuite manner on your favorite terraform provider

ootb function:
- ssh keys spread before deploy
- bootstrap node election

requirements:
- terraform
- a prepared image that accept cloud init data
- jq
- json2hcl

## example

clone this project

```
git clone https://github.com/automium/provisioner
cd provisioner
```

copy config.tf.example to config.tf and edit it
```
cp config.tf.example config.tf
```

`provisioner_role` and `provisioner_role_version` define which role and which version is used to be deployed

then deploy it
```
terraform init providers/openstack
terraform apply providers/openstack
```

## ansible role tags

use tag with `bootstrap` in your ansible role for task that must run one time on the leader (bootstrap) node  
use tag with `others` in your ansible role for task that must not run on leader node  
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
