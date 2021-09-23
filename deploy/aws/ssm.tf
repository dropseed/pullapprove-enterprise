resource "aws_ssm_parameter" "aws_iam_user_access_key_id" {
  name  = "/pullapprove${var.aws_unique_suffix}/aws_iam_user_access_key_id"
  type  = "SecureString"
  value = aws_iam_access_key.pullapprove.id
}

resource "aws_ssm_parameter" "aws_iam_user_secret_access_key" {
  name  = "/pullapprove${var.aws_unique_suffix}/aws_iam_user_secret_access_key"
  type  = "SecureString"
  value = aws_iam_access_key.pullapprove.secret
}

resource "aws_ssm_parameter" "github_app_webhook_secret" {
  name  = "/pullapprove${var.aws_unique_suffix}/github_app_webhook_secret"
  type  = "SecureString"
  value = var.github_app_webhook_secret
}

resource "aws_ssm_parameter" "github_app_private_key" {
  name  = "/pullapprove${var.aws_unique_suffix}/github_app_private_key"
  type  = "SecureString"
  value = var.github_app_private_key
}

resource "aws_ssm_parameter" "billing_api_url" {
  name  = "/pullapprove${var.aws_unique_suffix}/billing_api_url"
  type  = "SecureString"
  value = var.billing_api_url
}

resource "aws_ssm_parameter" "billing_api_secret" {
  name  = "/pullapprove${var.aws_unique_suffix}/billing_api_secret"
  type  = "SecureString"
  value = var.billing_api_secret
}

resource "aws_ssm_parameter" "availability_api_url" {
  name  = "/pullapprove${var.aws_unique_suffix}/availability_api_url"
  type  = "SecureString"
  value = var.availability_api_url
}

resource "aws_ssm_parameter" "availability_api_secret" {
  name  = "/pullapprove${var.aws_unique_suffix}/availability_api_secret"
  type  = "SecureString"
  value = var.availability_api_secret
}

resource "aws_ssm_parameter" "bitbucket_username_password" {
  name  = "/pullapprove${var.aws_unique_suffix}/bitbucket_username_password"
  type  = "SecureString"
  value = var.bitbucket_username_password
}

resource "aws_ssm_parameter" "gitlab_api_token" {
  name  = "/pullapprove${var.aws_unique_suffix}/gitlab_api_token"
  type  = "SecureString"
  value = var.gitlab_api_token
}
