resource "aws_lambda_function" "pullapprove_worker" {
  filename         = "${dirname(path.module)}/pullapprove_worker_aws.zip"
  function_name    = "pullapprove_worker"
  role             = "${aws_iam_role.pullapprove_lambda_role.arn}"
  handler          = "main.aws_sqs_handler"
  source_code_hash = "${base64sha256(file("${dirname(path.module)}/pullapprove_worker_aws.zip"))}"
  runtime          = "python3.6"
  timeout          = 300
  memory_size      = 128

  environment {
    variables = {
      AWS_SQS_NAME = "${aws_sqs_queue.pullapprove_worker_queue.name}"
      AWS_S3_BUCKET = "${aws_s3_bucket.pullapprove_storage_bucket.bucket}"
      GITHUB_APP_ID = "${var.github_app_id}"
      GITHUB_APP_PRIVATE_KEY = "${var.github_app_private_key}"
      GITHUB_API_BASE_URL = "${var.github_api_base_url}"
      GITHUB_STATUS_CONTEXT = "${var.github_status_context}"
      CONFIG_FILENAME = "${var.config_filename}"
      UI_BASE_URL = "http://${aws_s3_bucket.pullapprove_public_bucket.website_endpoint}/report/"
      SENTRY_DSN = "${var.sentry_dsn}"
      LOG_LEVEL = "${var.log_level}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "pullapprove_worker_event_source_mapping" {
  batch_size = 1
  event_source_arn = "${aws_sqs_queue.pullapprove_worker_queue.arn}"
  enabled = true
  function_name = "${aws_lambda_function.pullapprove_worker.arn}"
}
