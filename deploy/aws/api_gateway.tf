resource "aws_api_gateway_rest_api" "pullapprove_gateway" {
  name = "pullapprove${var.aws_unique_suffix}"
}

resource "aws_api_gateway_rest_api_policy" "pullapprove_gateway_iam_policy" {
  rest_api_id = aws_api_gateway_rest_api.pullapprove_gateway.id
  policy      = data.aws_iam_policy_document.pullapprove_gateway_iam_policy_document.json
}

data "aws_iam_policy_document" "pullapprove_gateway_iam_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.webhook_ip_allowlist
    }
  }
}

resource "aws_api_gateway_deployment" "pullapprove_deployment" {
  depends_on = [
    aws_api_gateway_integration.pullapprove_webhook_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.pullapprove_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.pullapprove_gateway.body,
      data.aws_iam_policy_document.pullapprove_gateway_iam_policy_document.json, # Redeploy when policy changes
      aws_lambda_permission.pullapprove_webhook_permission.source_arn, # Redeploy if related permission changes
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
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
