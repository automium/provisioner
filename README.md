# Kubernetes

define playbook for distributed infrastracture using terraform, consul and ansible

ootb function:
- ssh keys spread before deploy
- bootstrap node election
- lock management

requirements:
- consul
- terraform
- a prepared image that accept cloud init data

## example

clone this project

```
git clone https://github.com/automium/kubernetes
```

copy config.tf.example to config.tf and edit it
```
cp config.tf.example config.tf
```

edit main.yml for tasks that should run on all nodes. Use tag with bootstrap label for task that must run one time on the leader node
```
- name: this is task runs only on the bootstrap node
  package: name="{{ item }}"
  with_items:
    - nginx
    - haproxy
  tags:
    - bootstrap
- name: this is task runs on other node in parallel
  package: name=haproxy
```

then deploy it
```
terraform init providers/openstack
terraform apply providers/openstack
```
