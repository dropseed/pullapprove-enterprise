# AWS settings
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "aws_unique_suffix" {
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
variable "ui_base_url" {
  default = ""
  description = "The base url used to generate links to reports (leave blank to be automatically populated)"
}
# Note: these are single-space empty strings intentionally
# since SSM must have a value to store for these secrets
# - pullapprove will strip and detect these values are empty
variable "billing_api_url" {
  default = " "
  description = "URL to the billing API (not used for enterprise installations)"
}
variable "billing_api_secret" {
  default = " "
  description = "Secret for the billing API (not used for enterprise installations)"
}
variable "availability_api_url" {
  default = " "
  description = "URL to the availability API (not used for enterprise installations)"
}
variable "availability_api_secret" {
  default = " "
  description = "Secret for the availability API (not used for enterprise installations)"
}

# Lambda settings
variable "log_level" {
  default = "INFO"
  description = "Log level for lambda functions to enable more or less output"
}

variable "worker_memory" {
  default = 256
  description = "Memory limit on pullapprove worker"
}

# Optional error tracking
variable "sentry_dsn" {
  default = ""
  description = "Lambda errors can be sent to Sentry (https://sentry.io)"
}

variable "cache" {
  default = "file"
  description = "Enable API request caching. Set to an empty string to disable."
}

variable "pullapprove_version" {
  default = "3.9.0"
  description = "The version of PullApprove being deployed"
}

variable "assets_dir" {
  default = "../versions/3.9.0"
  description = "Path to the directory with assets for the version being deployed"
}
