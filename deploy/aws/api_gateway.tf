resource "aws_api_gateway_rest_api" "pullapprove_gateway" {
  name   = "pullapprove"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": ${var.webhook_ip_allowlist}
                }
            }
        }
    ]
  }
  POLICY
}

resource "aws_api_gateway_deployment" "pullapprove_deployment" {
  depends_on = [
    aws_api_gateway_integration.pullapprove_webhook_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.pullapprove_gateway.id
}

resource "aws_api_gateway_stage" "pullapprove_gateway_stage" {
  stage_name    = "production"
  rest_api_id   = aws_api_gateway_rest_api.pullapprove_gateway.id
  deployment_id = aws_api_gateway_deployment.pullapprove_deployment.id
}

resource "aws_api_gateway_method_settings" "pullapprove_webhook_proxy_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.pullapprove_gateway.id
  stage_name  = aws_api_gateway_stage.pullapprove_gateway_stage.stage_name
  method_path = "${aws_api_gateway_resource.pullapprove_webhook_proxy.path_part}/${aws_api_gateway_method.pullapprove_webhook_proxy_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }

  depends_on = [
    aws_api_gateway_account.pullapprove_cloudwatch_account
  ]
}
