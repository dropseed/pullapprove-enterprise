resource "aws_cloudwatch_dashboard" "pullapprove_cloudwatch_dashboard" {
  dashboard_name = "pullapprove${var.aws_unique_suffix}"
  dashboard_body = templatefile("${path.module}/dashboard.tpl",
    {
      aws_region            = var.aws_region,
      worker_function_name  = aws_lambda_function.pullapprove_worker.function_name,
      webhook_function_name = aws_lambda_function.pullapprove_webhook.function_name,
  })
}

resource "aws_cloudwatch_query_definition" "pullapprove_cloudwatch_query_report_urls" {
  name = "pullapprove${var.aws_unique_suffix}/Report URLs"

  log_group_names = [
    "/aws/lambda/${aws_lambda_function.pullapprove_worker.function_name}"
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter strcontains(@message, "canonical-log-line") and strcontains(@message, "report_url=http") and strcontains(@message, "repo=ORGNAME/")
| parse " repo=* " as repo
| parse " pr_number=* " as pr_number
| parse " pr_status=* " as pr_status
| parse " report_url=*" as report_url
| sort @timestamp desc
| limit 30
| display @timestamp, repo, pr_number, pr_status, report_url
EOF
}
