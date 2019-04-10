FROM ubuntu:18.04

# terraform
ENV TERRAFORM_VERSION=0.11.13
RUN apt-get update && \
    apt-get install curl unzip git -y && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform

# jq
RUN apt-get update && \
    apt-get install jq -y

# json2hcl
RUN curl https://github.com/kvz/json2hcl/releases/download/v0.0.6/json2hcl_v0.0.6_linux_amd64 -o /usr/local/bin/json2hcl && \
    chmod +x /usr/local/bin/json2hcl

# openstack
RUN apt-get update && apt-get install parallel python-pip -y && \
    python -m pip install --upgrade pip && \
    pip install --user python-swiftclient==3.6.0 python-openstackclient==3.17.0

# vsphere
ENV GOVC_LINK=https://github.com/vmware/govmomi/releases/download/v0.20.0/govc_linux_amd64.gz
RUN curl -L $GOVC_LINK | gunzip > /usr/local/bin/govc && \
    chmod +x /usr/local/bin/govc

# vcd
RUN apt-get update && apt-get install python-pip -y && \
    pip install --user vcd-cli


# TODO move in another part
RUN apt install gettext-base -y
ENV PATH=$PATH:/root/.local/bin/


COPY . /usr/src/provisioner

WORKDIR /usr/src/provisioner

CMD ["./deploy"]
