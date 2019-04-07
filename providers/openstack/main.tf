data "openstack_networking_network_v2" "network" {
  name = "${var.network_name}"
  region = "${var.region}"
}

data "openstack_networking_subnet_v2" "subnet" {
  network_id = "${data.openstack_networking_network_v2.network.id}"
  region = "${var.region}"
}

module "internal" {
  source = "github.com/automium/terraform-modules//openstack/security?ref=master"
  name = "internal"
  region = "${var.region}"
  protocol = ""
  allow_remote = "${data.openstack_networking_subnet_v2.subnet.cidr}"
}

module "instance" {
  source = "github.com/jsecchiero/terraform-modules//openstack/instance?ref=master"
  name = "${var.cluster_name == "" ? "${var.name}" : "${var.cluster_name}-${var.name}"}"
  region = "${var.region}"
  image = "${var.image}"
  quantity = "${var.quantity}"
  discovery = "false"
  flavor = "${var.flavor}"
  network_name = "${var.network_name}"
  sec_group = ["${module.internal.sg_id}"]
  keypair = "${var.keypair_name}"
  allowed_address_pairs = "0.0.0.0/0"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  postdestroy = "${data.template_file.cleanup.rendered}"
}
