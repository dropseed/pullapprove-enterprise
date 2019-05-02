# AWS settings
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "aws_bucket_suffix" {
  description = "-yourcompany"
}

# GitHub App settings
variable "github_app_id" {
  description = "ID for the GitHub App you created for PullApprove"
}
variable "github_api_base_url" {
  description = "Ex: https://github.yourcompany.com/api/v3"
}
variable "github_app_webhook_secret" {
  description = "The webhook secret for your GitHub App"
}
variable "github_app_private_key" {
  description = "The base64 encoded private key"
}
variable "github_bot_name" {
  default = "pullapprove[bot]"
  description = "The slugified name of your GitHub App. Should end in `[bot]`."
}

# Only change these if testing/staging a new version or something
variable "github_status_context" {
  default = "pullapprove"
  description = "The commit status \"context\" used in GitHub"
}
variable "config_filename" {
  default = ".pullapprove.yml"
  description = "Name of the PullApprove config file in each repo"
}

# Lambda settings
variable "log_level" {
  default = "INFO"
  description = "Log level for lambda functions to enable more or less output"
}

# Optional error tracking
variable "sentry_dsn" {
  default = ""
  description = "Lambda errors can be sent to Sentry (https://sentry.io)"
}
