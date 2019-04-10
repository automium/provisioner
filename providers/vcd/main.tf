module "instance" {
  source = "github.com/automium/terraform-modules//vcd/instance?ref=master"
  name = "${var.name}"
  quantity = "${var.quantity}"
  cpus = "${var.cpus}"
  memory = "${var.memory}"
  network_name = "${var.network_name}"
  template = "${var.template}"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  keypair = "${var.keypair}"
  vcd_username = "${var.vcd_username}" 
  vcd_password = "${var.vcd_password}"
  vcd_org = "${var.vcd_org}"
  vcd_vdc = "${var.vcd_vdc}"
  vcd_url = "${var.vcd_url}"
  vcd_server = "${var.vcd_server}"
  catalog = "${var.catalog}"
  discovery = "true"
  discovery_port = "2380"
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
