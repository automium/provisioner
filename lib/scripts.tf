data "local_file" "config" {
  filename = "config.tf"
}

data "local_file" "header" {
  filename = "lib/cloud-config/header.yml.part"
}

data "local_file" "footer" {
  filename = "lib/cloud-config/footer.yml.part"
}

data "local_file" "provisioner" {
  filename = "lib/cloud-config/provisioner.yml"
}

data "template_file" "cloud-config" {
  template = <<EOF
${data.local_file.header.content}
      ${indent(6,data.local_file.provisioner.content)}
${data.local_file.footer.content}
EOF
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
