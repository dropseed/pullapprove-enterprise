resource "aws_iam_role" "pullapprove_lambda_role" {
  name = "pullapprove"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "pullapprove_logging_policy" {
  name = "pullapprove_logging"
  path = "/"
  description = "IAM policy for logging from PullApprove"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pullapprove_logging_attachment" {
  role = "${aws_iam_role.pullapprove_lambda_role.name}"
  policy_arn = "${aws_iam_policy.pullapprove_logging_policy.arn}"
}

resource "aws_iam_policy" "pullapprove_sqs_policy" {
  name = "pullapprove_sqs"
  path = "/"
  description = "IAM policy for PullApprove SQS access"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [{
         "Effect": "Allow",
         "Action": "sqs:*",
         "Resource": "${aws_sqs_queue.pullapprove_worker_queue.arn}"
   }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pullapprove_sqs_attachment" {
  role = "${aws_iam_role.pullapprove_lambda_role.name}"
  policy_arn = "${aws_iam_policy.pullapprove_sqs_policy.arn}"
}
