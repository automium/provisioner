module "instance" {
  source = "github.com/automium/terraform-modules//vcd/instance?ref=1.0.14"
  name = "${var.cluster_name == "" ? "${var.name}" : "${var.cluster_name}-${var.name}"}"
  quantity = "${var.quantity}"
  cpus = "${var.cpus}"
  memory = "${var.memory}"
  disk = "${var.disk}"
  network_name = "${var.network_name}"
  template = "${var.image}"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  keypair = "${var.keypair}"
  postdestroy = "${data.template_file.cleanup.rendered}"
  vcd_username = "${var.vcd_username}" 
  vcd_password = "${var.vcd_password}"
  vcd_org = "${var.vcd_org}"
  vcd_vdc = "${var.vcd_vdc}"
  vcd_url = "${var.vcd_url}"
  vcd_server = "${var.vcd_server}"
  catalog = "${var.vcd_catalog}"
}
