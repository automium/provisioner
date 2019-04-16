# Provisioner

deploy ansible role in a distribuite manner on your favorite terraform provider

the automium provisioner take care for two special tags for bootstrap your cluster

## Tags

### bootstrap

is used for task that must run one time on the leader (bootstrap) node. Es. initialize the cluster
### others

is used for task that must not run on leader node, but on the others nodes. Es. manage scale up of the cluster

## Variables

the variables are passed to the role using config.tf

## example

create a .env file, see .env.example

`PROVISIONER_ROLE` and `PROVISIONER_ROLE_VERSION` define which role and which version is used to be deployed

then deploy it
```
docker-compose pull
docker-compose run --rm deploy
```

## contribute

download the repo
```
git clone https://github.com/automium/provisioner.git
cd provisioner
```

edit, build and test locally
```
docker-compose pull
docker-compose -f docker-compose.dev.yml build --no-cache --pull
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run --rm deploy
```
