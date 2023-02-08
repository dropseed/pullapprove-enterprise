resource "aws_lambda_function" "pullapprove_webhook" {
  filename         = "${var.assets_dir}/pullapprove_webhook_aws.zip"
  function_name    = "pullapprove_webhook${var.aws_unique_suffix}"
  role             = aws_iam_role.pullapprove_lambda_role.arn
  handler          = "main.aws_handler"
  source_code_hash = filebase64sha256("${var.assets_dir}/pullapprove_webhook_aws.zip")
  runtime          = "python3.8"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      AWS_SSM_PARAMETER_PATH       = "/pullapprove${var.aws_unique_suffix}"
      AWS_SQS_NAME                 = aws_sqs_queue.pullapprove_worker_queue.name
      GITHUB_STATUS_CONTEXT        = var.github_status_context
      BITBUCKET_STATUS_KEY         = var.bitbucket_status_key
      CONFIG_FILENAME              = var.config_filename
      WEBHOOK_REPO_BLOCKLIST       = join(",", var.webhook_repo_blocklist)
      WEBHOOK_SENDER_BLOCKLIST     = join(",", var.webhook_sender_blocklist)
      WEBHOOK_EXPRESSION_BLOCKLIST = jsonencode(var.webhook_expression_blocklist)
      GITHUB_BOT_NAME              = var.github_bot_name
      SENTRY_DSN                   = var.sentry_dsn
      SENTRY_ENVIRONMENT           = var.sentry_env
      LOG_LEVEL                    = var.log_level
      VERSION                      = var.pullapprove_version
    }
  }
}

resource "aws_lambda_permission" "pullapprove_webhook_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pullapprove_webhook.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.pullapprove_gateway.execution_arn}/${aws_api_gateway_stage.pullapprove_gateway_stage.stage_name}/${aws_api_gateway_method.pullapprove_webhook_proxy_method.http_method}${aws_api_gateway_resource.pullapprove_webhook_proxy.path}"
}

resource "aws_api_gateway_resource" "pullapprove_webhook_proxy" {
  rest_api_id = aws_api_gateway_rest_api.pullapprove_gateway.id
  parent_id   = aws_api_gateway_rest_api.pullapprove_gateway.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "pullapprove_webhook_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.pullapprove_gateway.id
  resource_id   = aws_api_gateway_resource.pullapprove_webhook_proxy.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "pullapprove_webhook_integration" {
  rest_api_id = aws_api_gateway_rest_api.pullapprove_gateway.id
  resource_id = aws_api_gateway_method.pullapprove_webhook_proxy_method.resource_id
  http_method = aws_api_gateway_method.pullapprove_webhook_proxy_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.pullapprove_webhook.invoke_arn
}

output "pullapprove_webhook_url" {
  value = "${aws_api_gateway_stage.pullapprove_gateway_stage.invoke_url}/${aws_api_gateway_resource.pullapprove_webhook_proxy.path_part}"
}

output "pullapprove_webhook_function" {
  value = aws_lambda_function.pullapprove_webhook
}
