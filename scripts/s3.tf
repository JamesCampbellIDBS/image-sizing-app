# Bucket Replication. Need to specify a diff provider when creating replica bucket
provider "aws" {
  alias  = "replica"
  region = local.replica_region
  assume_role {
    role_arn   = var.aws_role_arn
  }
}

# Primary/Main bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = "${local.general_resource_name}-bucket"
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.logging_bucket.id
  }

  acl = "public-read"

  replication_configuration {
    role = aws_iam_role.replication.arn
    rules {
      status = "Enabled"
      destination {
        bucket = aws_s3_bucket.replica_bucket.arn
        storage_class = "STANDARD_IA"
      }
    }
  }
}

# Replication Bucket
resource "aws_s3_bucket" "replica_bucket" {
  bucket        = "${local.general_resource_name}-replica-bucket"
  provider      = aws.replica
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
      }
    }
  }
}

# Logging Bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "${local.general_resource_name}-log-bucket"
  acl           = "log-delivery-write"
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
      }
    }
  }
}

resource "aws_iam_role" "replication" {
  permissions_boundary = var.permissions_boundary
  name                  = "${local.general_resource_name}-replication-role"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name   = "${local.general_resource_name}-replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.replica_bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}
