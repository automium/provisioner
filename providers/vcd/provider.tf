provider "vcd" {
 user = "${var.vcd_username}"
 password = "${var.vcd_password}"
 org = "${var.vcd_org}"
 url = "${var.vcd_url}/api/"
 vdc = "${var.vcd_vdc}"
}
