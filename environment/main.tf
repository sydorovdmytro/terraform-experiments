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

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  vpc_cidr_block = "10.0.0.0/16"
  azs            = data.aws_availability_zones.available.names

  public_subnets = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr_block, 8, idx + length(local.azs))]

  vcluster_name = nonsensitive(var.vcluster.name)
  region        = nonsensitive(var.vcluster.requirements["region"])
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = local.vpc_cidr_block

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  one_nat_gateway_per_az = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

