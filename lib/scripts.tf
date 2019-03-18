data "local_file" "cloud-config" {
  filename = "main.yml"
}

data "template_file" "cloud-config" {
  template = "${data.local_file.cloud-config.content}"
  count = "${var.quantity}"
  vars {
    name = "${var.cluster_name}-${var.name}"
    number = "${count.index}"
    hostname = "${var.name}-${count.index}"
    quantity = "${var.quantity}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}

data "local_file" "cleanup" {
  filename = "lib/cleanup.sh"
}

data "template_file" "cleanup" {
  template = "${data.local_file.cleanup.content}"
  vars {
    name = "${var.cluster_name}-${var.name}"
    quantity = "${var.quantity}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}
