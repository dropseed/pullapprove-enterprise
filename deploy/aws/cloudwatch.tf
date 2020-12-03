resource "aws_cloudwatch_dashboard" "pullapprove_cloudwatch_dashboard" {
  dashboard_name = "PullApprove"
  dashboard_body = templatefile("${path.module}/dashboard.tpl",
    {
      aws_region            = var.aws_region,
      worker_function_name  = aws_lambda_function.pullapprove_worker.function_name,
      webhook_function_name = aws_lambda_function.pullapprove_webhook.function_name,
  })
}
