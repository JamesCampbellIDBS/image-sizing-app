variable "env" {
  type        = string
  description = "one of dev, prod"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources to"
}

variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume"
}

variable "resource_owner" {
  type        = string
  description = "Used for tagging resources. Typically the Dept, or Customer name"
}

variable "sse_algorithm" {
  type        = string
  description = "The server-side encryption algorithm to use with the s3 buckets"
  default     = "AES256"
}

variable "permissions_boundary" {
  description = "Permission boundary to use for iam creation"
  type        = string
}

variable "lambda_timeout" {
  type        = number
  description = "The Lambda execution timeout value(s)"
  default     = 60
}

variable "lambda_memory_size" {
  type        = number
  description = "The memory(MB) allocation of the Lambda"
  default     = 5120
}

variable "domain" {
  type        = string
  description = "The name of the hosted zone to use"
}