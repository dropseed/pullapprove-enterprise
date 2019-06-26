resource "aws_ssm_parameter" "aws_iam_user_access_key_id" {
  name        = "/pullapprove${var.aws_unique_suffix}/aws_iam_user_access_key_id"
  type        = "SecureString"
  value       = "${aws_iam_access_key.pullapprove.id}"
}

resource "aws_ssm_parameter" "aws_iam_user_secret_access_key" {
  name        = "/pullapprove${var.aws_unique_suffix}/aws_iam_user_secret_access_key"
  type        = "SecureString"
  value       = "${aws_iam_access_key.pullapprove.secret}"
}

resource "aws_ssm_parameter" "github_app_webhook_secret" {
  name        = "/pullapprove${var.aws_unique_suffix}/github_app_webhook_secret"
  type        = "SecureString"
  value       = "${var.github_app_webhook_secret}"
}

resource "aws_ssm_parameter" "github_app_private_key" {
  name        = "/pullapprove${var.aws_unique_suffix}/github_app_private_key"
  type        = "SecureString"
  value       = "${var.github_app_private_key}"
}
