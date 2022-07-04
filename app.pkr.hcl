locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  name = "tt-api"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name = "${local.name}-${local.timestamp}"
  tags = {
    Application = "${local.name}"
  }
  instance_type = "t2.micro"
  region        = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::548930680747:role/tt-role"
    session_name = "packer"
  }
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "tt-api"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "index.js"
    destination = "/tmp/index.js"
  }

  provisioner "file" {
    source      = "package.json"
    destination = "/tmp/package.json"
  }

  provisioner "file" {
    source      = "package-lock.json"
    destination = "/tmp/package-lock.json"
  }

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    script = "app-init.sh"
  }

}
