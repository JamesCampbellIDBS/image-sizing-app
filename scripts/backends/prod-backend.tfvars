bucket                = "prod-terraform-state"
region                = "eu-west-1"
dynamodb_table        = "prod-terraform-state-lock"
role_arn              = "arn:aws:iam::<AWS-ACC-ID>:role/prod-terraform-state-access"
workspace_key_prefix  = "sre/image-resize/envs:"
key                   = "terraform.state"