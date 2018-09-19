# AWS settings
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

# GitHub App settings
variable "github_app_id" {
  description = "ID for the GitHub App you created for PullApprove"
}
variable "github_api_base_url" {
  description = "Ex: https://github.yourcompany.com/api/v3"
}
variable "github_app_webhook_secret" {}
variable "github_app_private_key" {
  description = "The base64 encoded private key"
}

# Only change these if testing/staging a new version or something
variable "github_status_context" {
  default = "pullapprove"
}
variable "config_filename" {
  default = ".pullapprove.yml"
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
