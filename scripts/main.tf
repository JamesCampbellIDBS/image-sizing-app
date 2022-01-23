terraform {
 backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }
}

data "aws_caller_identity" "this" {}

locals {
  general_resource_name = "image-resizer-${var.env}-${terraform.workspace}"
  aws_acc_id  = data.aws_caller_identity.this.account_id
  tags = {
    resource_owner                                 = var.resource_owner
    created_by                                     = "Terraform"
    Environment                                    = var.env
    Application                                    = terraform.workspace
    }
  region_to_replicate = {
    "eu-west-1"      = "eu-central-1",
    "eu-west-3"      = "eu-central-1",
    "eu-west-2"      = "eu-west-1"
    "us-east-1"      = "us-west-2",
    "us-west-2"      = "us-east-1",
    "us-west-1"      = "us-west-2",
    "eu-central-1"   = "eu-west-1",
    "ap-northeast-1" = "ap-southeast-1",
    "ap-northeast-2" = "ap-southeast-1"
    "ap-southeast-1" = "ap-southeast-2",
    "ap-south-1"     = "ap-southeast-1",
    "ap-southeast-2" = "us-west-2"}

  replica_region = lookup(local.region_to_replicate, var.aws_region)
  domain_name = var.domain
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn =var.aws_role_arn
  }
  default_tags = {
    tags = local.tags
  }
}

resource "aws_lambda_function" "lambda" {
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name = "${local.general_resource_name}-lambda"
  handler = "app.lambdaHandler"
  role = aws_iam_role.lambda_image_resizer.arn
  runtime = "nodejs14.x"
  memory_size = var.lambda_memory_size
  timeout = var.lambda_timeout

  environment {
    variables = {
      S3_BUCKET = "${local.general_resource_name}-bucket"
    }
  }
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/lambda.js.zip"
}