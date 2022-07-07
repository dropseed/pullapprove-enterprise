resource "aws_lambda_function" "pullapprove_worker" {
  filename         = "${var.assets_dir}/pullapprove_worker_aws.zip"
  function_name    = "pullapprove_worker${var.aws_unique_suffix}"
  role             = aws_iam_role.pullapprove_lambda_role.arn
  handler          = "main.aws_sqs_handler"
  source_code_hash = filebase64sha256("${var.assets_dir}/pullapprove_worker_aws.zip")
  runtime          = "python3.8"
  timeout          = 300
  memory_size      = var.worker_memory

  environment {
    variables = {
      AWS_SSM_PARAMETER_PATH = "/pullapprove${var.aws_unique_suffix}"
      AWS_SQS_NAME           = aws_sqs_queue.pullapprove_worker_queue.name
      AWS_S3_BUCKET          = aws_s3_bucket.pullapprove_storage_bucket.bucket
      GITHUB_APP_ID          = var.github_app_id
      GITHUB_API_BASE_URL    = var.github_api_base_url
      GITHUB_STATUS_CONTEXT  = var.github_status_context
      BITBUCKET_STATUS_KEY   = var.bitbucket_status_key
      GITLAB_API_BASE_URL    = var.gitlab_api_base_url
      GITLAB_STATUS_NAME     = var.gitlab_status_name
      CONFIG_FILENAME        = var.config_filename
      UI_BASE_URL            = var.ui_base_url != "" ? var.ui_base_url : "http://${aws_s3_bucket.pullapprove_public_bucket.website_endpoint}/report/"
      SENTRY_DSN             = var.sentry_dsn
      SENTRY_ENVIRONMENT     = var.sentry_env
      LOG_LEVEL              = var.log_level
      CACHE                  = var.cache
      CACHE_REDIS_OPTIONS    = jsonencode(var.cache_redis_options)
      VERSION                = var.pullapprove_version
      REPORT_EXPIRATION_DAYS = var.report_expiration_days
    }
  }

  vpc_config {
    # To set the worker VPC, either use these variables (useful if using pullapprove as a module)
    # or manually replace these with references to additional Terraform resources in this repo
    subnet_ids         = var.worker_vpc_config.subnet_ids
    security_group_ids = var.worker_vpc_config.security_group_ids
  }
}

resource "aws_lambda_event_source_mapping" "pullapprove_worker_event_source_mapping" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.pullapprove_worker_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.pullapprove_worker.arn
}
