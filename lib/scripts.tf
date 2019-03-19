data "local_file" "config" {
  filename = "config.tf"
}

data "local_file" "cloud-config" {
  filename = "main.yml"
}

data "template_file" "cloud-config" {
  template = "${data.local_file.cloud-config.content}"
  count = "${var.quantity}"
  vars {
    config = "${indent(6,data.local_file.config.content)}"
    number = "${count.index}"
  }
}

data "local_file" "cleanup" {
  filename = "lib/cleanup.sh"
}

data "template_file" "cleanup" {
  template = "${data.local_file.cleanup.content}"
  vars {
    config = "${data.local_file.config.content}"
  }
}
