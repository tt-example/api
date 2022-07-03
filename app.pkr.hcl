locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "name" {
  type    = string
  default = "tt-api"
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
  ami_name = "${var.name}-${local.timestamp}"
  tags = {
    Application = var.name
  }
  instance_type = "t2.micro"
  region        = "eu-west-2"
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
  name = var.name
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
