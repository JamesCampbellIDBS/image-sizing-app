variable "env" {
  type        = string
  description = "one of dev, prod"
}

variable "aws_region" {
  type = string
  description = "The AWS region to deploy resources to"
}

variable "aws_role_arn" {
  type = string
  description = "The AWS Role ARN to assume"
}

variable "resource_owner" {
  type = string
  description = "Used for tagging resources. Typically the Dept, or Customer name"
}