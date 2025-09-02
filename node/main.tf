terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.vcluster.requirements["region"]

  default_tags {
    tags = {
      "vcluster:name"      = var.vcluster.instance.metadata.name
      "vcluster:namespace" = var.vcluster.instance.metadata.namespace
    }
  }
}

locals {
  vcluster_name = nonsensitive(var.vcluster.name)
  region        = nonsensitive(var.vcluster.requirements["region"])
}

data "aws_ssm_parameter" "ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# VM
resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.ami_id.insecure_value
  instance_type               = var.vcluster.requirements["instance-type"]
  subnet_id                   = var.vcluster.nodeEnvironment.outputs["private_subnet_ids"][0]
  vpc_security_group_ids      = [var.vcluster.nodeEnvironment.outputs["security_group_id"]]
  user_data                   = var.vcluster.userData
  user_data_replace_on_change = true

  # --- Root disk sizing ---
  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.vcluster.name}-ec2"
  }
}
