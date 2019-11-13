# provisioner

[![Build Status](https://travis-ci.org/automium/provisioner.svg?branch=master)](https://travis-ci.org/automium/provisioner)

deploy ansible role in a distribuite manner on your favorite terraform provider

the automium provisioner take care for two special tags for bootstrap your cluster

## variables

TODO list the variables here

### PROVISIONER_CONFIG_WAIT_CLEANUP
if true the provisoiner waits until cleanup is done

### PROVISIONER_CONFIG_WAIT_CLEANUP_TIMEOUT
number of retry before timeout. Waiting time between one
retry and another is 1s.
_Default 30_

### NETWORK_SECURITY_PORTS
a list of maximum 10 ports or ranges e.g.
```
80,443,10000-20000
```

### SENTRY_DSN
DSN where to send log with sentry
```
https://<key>:<secret>@sentry.io/<project>
```

### TELEGRAM_BOT_TOKEN _optional_
require TELEGRAM_CHAT_ID
used for send notification to telegram
```
125934871:AxFZ65hflxz9qEGI8zwS8p_hb2mxptGAm13
```

### TELEGRAM_CHAT_ID _optional_
require TELEGRAM_BOT_TOKEN
used for send notification to telegram
```
-127989562
```

### AVAILABILITY_ZONES
in which availability zones the provisioner will spread the instances in a round robin fashion
the zones must be comma delimited
```
"north_city","south_city"
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

TODO better explain the tags workflow

### bootstrap

is used for task that must run one time on the leader (bootstrap) node. Es. initialize the cluster

### others

is used for task that must not run on leader node, but on the others nodes. Es. manage scale up of the cluster
