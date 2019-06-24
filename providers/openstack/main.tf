data "openstack_networking_network_v2" "network" {
  name = "${var.os_network_name}"
  region = "${var.os_region}"
}

data "openstack_networking_subnet_v2" "subnet" {
  network_id = "${data.openstack_networking_network_v2.network.id}"
  region = "${var.os_region}"
}

module "internal" {
  source = "github.com/automium/terraform-modules//openstack/security?ref=1.0.5"
  name = "internal"
  region = "${var.os_region}"
  protocol = ""
  allow_remote = "${data.openstack_networking_subnet_v2.subnet.cidr}"
}

module "instance" {
  source = "github.com/automium/terraform-modules//openstack/instance?ref=1.0.5"
  name = "${var.cluster_name == "" ? "${var.name}" : "${var.cluster_name}-${var.name}"}"
  region = "${var.os_region}"
  image = "${var.image}"
  quantity = "${var.quantity}"
  discovery = "false"
  flavor = "${var.flavor}"
  network_name = "${var.os_network_name}"
  sec_group = ["${module.internal.sg_id}"]
  keypair = "${var.keypair_name}"
  allowed_address_pairs = "0.0.0.0/0"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  postdestroy = "${data.template_file.cleanup.rendered}"
  auth_url = "${var.os_auth_url}"
  tenant_name = "${var.os_tenant_name}"
  user_name = "${var.os_user_name}"
  password = "${var.os_password}"
}
