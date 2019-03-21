data "local_file" "config" {
  filename = "config.tf"
}

data "local_file" "header" {
  filename = "lib/cloud-config/header.yml.part"
}

data "local_file" "footer" {
  filename = "lib/cloud-config/footer.yml.part"
}

data "local_file" "ssh-keys" {
  filename = "lib/cloud-config/ssh-keys.yml"
}

data "template_file" "cloud-config" {
  template = <<EOF
${data.local_file.header.content}
      ${indent(6,data.local_file.ssh-keys.content)}
      ${indent(6,data.external.cloud-config.result.output)}
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

data "external" "cloud-config" {
  program = [
    "/bin/bash",
    "-c",
    <<EOF
OUTPUT=$(cat src/*)
jq -r -n --arg output "$${OUTPUT}" '{"output":$output}'
EOF
  ]
}
