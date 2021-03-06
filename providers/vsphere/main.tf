module "instance" {
  source = "github.com/automium/terraform-modules//vsphere/instance?ref=1.0.11"
  name = "${var.cluster_name == "" ? "${var.name}" : "${var.cluster_name}-${var.name}"}"
  quantity = "${var.quantity}"
  cpus = "${var.cpus}"
  memory = "${var.memory}"
  network_name = "${var.network_name}"
  datastore = "${var.datastore}"
  iso_datastore = "${var.iso_datastore}"
  template_datastore = "${var.template_datastore}"
  datacenter = "${var.datacenter}"
  root_folder = "${var.root_folder}"
  folder = "${var.folder}"
  cluster = "${var.cluster}"
  template = "${var.image}"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  postdestroy = "${data.template_file.cleanup.rendered}"
  vsphere_user = "${var.vsphere_user}"
  vsphere_password = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  vsphere_insecure = "${var.vsphere_insecure}"
  keypair = "${var.keypair}"
}
