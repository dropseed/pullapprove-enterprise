resource "aws_lambda_function" "pullapprove_webhook" {
  filename         = "${dirname(path.module)}/pullapprove_webhook_aws.zip"
  function_name    = "pullapprove_webhook"
  role             = "${aws_iam_role.pullapprove_lambda_role.arn}"
  handler          = "main.aws_handler"
  source_code_hash = "${base64sha256(file("${dirname(path.module)}/pullapprove_webhook_aws.zip"))}"
  runtime          = "python3.6"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      AWS_SQS_NAME = "${aws_sqs_queue.pullapprove_worker_queue.name}"
      GITHUB_APP_WEBHOOK_SECRET = "${var.github_app_webhook_secret}"
      GITHUB_STATUS_CONTEXT = "${var.github_status_context}"
      CONFIG_FILENAME = "${var.config_filename}"
      SENTRY_DSN = "${var.sentry_dsn}"
      LOG_LEVEL = "${var.log_level}"
    }
  }
}

resource "aws_lambda_permission" "pullapprove_webhook_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.pullapprove_webhook.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_resource" "pullapprove_webhook_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.pullapprove_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.pullapprove_gateway.root_resource_id}"
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "pullapprove_webhook_proxy_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.pullapprove_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.pullapprove_webhook_proxy.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "pullapprove_webhook_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.pullapprove_gateway.id}"
  resource_id = "${aws_api_gateway_method.pullapprove_webhook_proxy_method.resource_id}"
  http_method = "${aws_api_gateway_method.pullapprove_webhook_proxy_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.pullapprove_webhook.invoke_arn}"
}

output "github_app_webhook_url" {
  value = "${aws_api_gateway_deployment.pullapprove_deployment.invoke_url}/${aws_api_gateway_resource.pullapprove_webhook_proxy.path_part}"
}
