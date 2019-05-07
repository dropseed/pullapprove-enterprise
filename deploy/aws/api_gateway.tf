resource "aws_api_gateway_rest_api" "pullapprove_gateway" {
  name = "pullapprove"
}

resource "aws_api_gateway_deployment" "pullapprove_deployment" {
  depends_on = [
    "aws_api_gateway_integration.pullapprove_webhook_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.pullapprove_gateway.id}"
  stage_name  = "production"
}
