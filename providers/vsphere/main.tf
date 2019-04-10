module "instance" {
  source = "github.com/automium/terraform-modules//vsphere/instance?ref=master"
  name = "${var.name}"
  quantity = "${var.quantity}"
  cpus = "${var.cpus}"
  memory = "${var.memory}"
  network_name = "${var.network_name}"
  datastore = "${var.datastore}"
  iso_datastore = "${var.iso_datastore}"
  template_datastore = "${var.template_datastore}"
  datacenter = "${var.datacenter}"
  cluster = "${var.cluster}"
  template = "${var.template}"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  vsphere_user = "${var.vsphere_user}"
  vsphere_password = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  keypair = "${var.keypair}"
}

data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.yml")}"
  vars {
    etcd_token = "${random_string.cluster-token.result}"
    name = "${var.name}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}

resource "random_string" "cluster-token" {
  length = 32
  special = false
}

output "cluster-token" {
  value = "${random_string.cluster-token.result}"
}
