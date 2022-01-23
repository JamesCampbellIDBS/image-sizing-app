resource "aws_iam_role" "lambda_image_resizer" {
  name                 = "${local.general_resource_name}-role"
  permissions_boundary = "arn:aws:iam::${local.aws_acc_id}:policy/restricted/deployment_permissions_boundary"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "generic_logs_policy" {
  role       = aws_iam_role.lambda_image_resizer.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "push_to_s3_bucket" {
  name = "${local.general_resource_name}-policy"
  role = aws_iam_role.lambda_image_resizer.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:ListBucket",
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.bucket.arn}",
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3::::${aws_s3_bucket.bucket.arn}",
          "arn:aws:s3::::${aws_s3_bucket.bucket.arn}/*",
        ]
      }
    ]
  })
}