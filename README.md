# provisioner

[![Build Status](https://travis-ci.org/automium/provisioner.svg?branch=master)](https://travis-ci.org/automium/provisioner)

deploy ansible role in a distribuite manner on your favorite terraform provider

## variables

### common

variables used generically for every provider  
</br>

#### PROVISIONER_CONFIG_WAIT_CLEANUP

if true the provisoiner waits until cleanup is done

#### PROVISIONER_CONFIG_WAIT_CLEANUP_TIMEOUT

number of retry before timeout. Waiting time between one
retry and another is 1s.
_Default 30_

#### SENTRY_DSN

DSN where to send log with sentry
```
https://<key>:<secret>@sentry.io/<project>
```

#### TELEGRAM_BOT_TOKEN _optional_

require TELEGRAM_CHAT_ID
used for send notification to telegram
```
125934871:AxFZ65hflxz9qEGI8zwS8p_hb2mxptGAm13
```

#### TELEGRAM_CHAT_ID _optional_

require TELEGRAM_BOT_TOKEN
used for send notification to telegram
```
-127989562
```

#### AVAILABILITY_ZONES
_doesn't work on vsphere and vcd_

in which availability zones the provisioner will spread the instances in a round robin fashion
the zones must be comma delimited
```
"north_city","south_city"
```

#### NETWORK_SECURITY_PORTS
_doesn't work on vsphere and vcd_

a list of maximum 10 ports or ranges e.g.
```
80,443,10000-20000
```

#### SERVER_GROUP_POLICY

_openstack_ (default: "anti-affinity")  

must be one of "affinity" or "anti-affinity"

#### FLAVOR

deploy instances with provider exposed flavors.  

On vsphere or vcd does not exist so an abstraction is used instead.
Separeted by a minus
- the first field is the number of CPUs
- the second are the MB of memory.
- the thirth are the MB of OS disk.
```
4-8192-102400 # is 4 CPUs, 8GB of memory and 102400MB of disk
```

### openstack

provider specific variables for openstack
```
KEYPAIR_NAME=
OS_NETWORK_NAME=
FLAVOR=1.standard.1
OS_REGION_NAME=
OS_AUTH_URL=
OS_TENANT_NAME=
OS_TENANT_ID=
OS_USERNAME=
OS_PASSWORD=
```

### vsphere

provider specific variables for vsphere
```
VSPHERE_USERNAME=
VSPHERE_PASSWORD=
VSPHERE_SERVER=
NETWORK_NAME=
CLUSTER=
FLAVOR=4-8192-102400
DATACENTER=
DATASTORE=
ISO_DATASTORE=
KEYPAIR= # Public ssh key
TEMPLATE_DATASTORE=
```

### vcd

provider specific variables for vcd
```
VCD_CATALOG=
VCD_ORG=
VCD_PASSWORD=
VCD_SERVER=
VCD_URL=
VCD_USERNAME=
VCD_VDC=
FLAVOR=4-8192-102400
NETWORK_CIDR=
NETWORK_NAME=
KEYPAIR= # Public ssh key
```

## usage

create a .env file, see [.env.example](https://raw.githubusercontent.com/automium/provisioner/master/.env.example) and download the composes
```
curl -Ss https://raw.githubusercontent.com/automium/provisioner/master/docker-compose.yml > docker-compose.yml
```

### deploy

```
docker-compose pull
docker-compose run --rm deploy
```

### rolling upgrade

```
docker-compose pull
docker-compose run --rm upgrade
```

### apply

call terraform apply directly without waiting readiness
```
docker-compose pull
docker-compose run --rm apply
```

## contribute

download the repo and make your changes
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

## tags

the automium provisioner take care for two special tags for bootstrap your cluster

### bootstrap

is used for task that must run one time on the leader (bootstrap) node. Es. initialize the cluster

### others

is used for task that must not run on leader node, but on the others nodes. Es. manage scale up of the cluster
