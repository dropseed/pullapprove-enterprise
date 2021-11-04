resource "aws_sqs_queue" "pullapprove_worker_queue" {
  name                       = "pullapprove_worker_queue${var.aws_unique_suffix}"
  visibility_timeout_seconds = 300 // needs to be at least as high as worker timeout
  message_retention_seconds  = 3600
}
