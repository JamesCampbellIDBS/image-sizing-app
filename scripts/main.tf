terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }
}

locals {
  tags = {
    resource_owner                                 = var.resource_owner
    created_by                                     = "Terraform"
    Environment                                    = var.env
    Application                                    = terraform.workspace
    }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn =var.aws_role_arn
  }
  default_tags {
    tags = local.tags
  }
}

