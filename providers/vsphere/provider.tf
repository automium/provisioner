provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server_port == "" ? "${var.vsphere_server}" : "${var.vsphere_server}:${var.vsphere_server_port}"}"
  allow_unverified_ssl = "${var.vsphere_insecure == "1" ? "true" : "false" }"
}
