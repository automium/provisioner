FROM golang AS build-env
RUN go get github.com/palantir/tfjson && \
    cd $GOPATH/src/github.com/palantir/tfjson && \
    rm -rf vendor && \
    go get -v ./... && \
    sed -i 's/t\.Helper/\/\/t\.Helper/g' ../../hashicorp/terraform/config/testing.go && \
    cd $GOPATH/src/github.com/hashicorp/terraform && \
    git checkout v0.11 && \
    cd $GOPATH/src/github.com/palantir/tfjson && \
    go get -v ./... && \
    go install ./...

FROM ubuntu:18.04

# tfjson
COPY --from=build-env /go/bin/tfjson /usr/local/bin/tfjson

# terraform
ENV TERRAFORM_VERSION=0.11.13
RUN apt-get update && \
    apt-get install curl wget unzip git -y && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform

# json2hcl
RUN curl -L https://github.com/kvz/json2hcl/releases/download/v0.0.6/json2hcl_v0.0.6_linux_amd64 -o /usr/local/bin/json2hcl && \
    chmod +x /usr/local/bin/json2hcl

# openstack
RUN apt-get update && apt-get install parallel python3 python3-pip -y && \
    pip3 install --user python-swiftclient==3.6.0 python-openstackclient==5.2.1

# xq
RUN apt-get update && apt-get install python3-pip -y && \
    pip3 install --user yq==2.9.2

# vsphere
ENV GOVC_LINK=https://github.com/vmware/govmomi/releases/download/v0.20.0/govc_linux_amd64.gz
RUN curl -L $GOVC_LINK | gunzip > /usr/local/bin/govc && \
    chmod +x /usr/local/bin/govc && \
    apt update && apt-get install genisoimage -y

# vcd
RUN apt-get update && apt-get install python3-pip -y && \
    pip3 install --user vcd-cli==22.0.0 pyvcloud==21.0.1.dev3

# sentry
RUN curl -sL https://sentry.io/get-cli/ | bash

# tools
RUN apt-get update && \
    apt-get install jq bc gettext-base -y && \
    pip3 install --user j2cli

# debug
RUN apt-get install vim -y

ENV PATH=$PATH:/root/.local/bin/

COPY . /usr/src/provisioner

WORKDIR /usr/src/provisioner

ENV LC_ALL C.UTF-8
ENV PROVISIONER_CONFIG_WAIT_CLEANUP false
ENV PROVISIONER_CONFIG_WAIT_CLEANUP_TIMEOUT 35

CMD ["./deploy"]
