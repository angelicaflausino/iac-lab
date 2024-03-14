terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = var.region_aws
}

resource "aws_instance" "app_server" {
    ami = var.instance_ami
    instance_type = var.instance_size
    key_name = var.ssh_key
    tags = {
      Name = "IACLABMOD2"
    }
}

resource "aws_key_pair" "ssh_key_env" {
  key_name = var.ssh_key
  public_key = file("${var.ssh_key}.pub")
}

output "PUBLIC_IP" {
  value = aws_instance.app_server.public_ip
}
