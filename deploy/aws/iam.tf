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

# SQS
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

# also set up an iam user, so that we can sign urls with a longer expiration
# than we can with a role
resource "aws_iam_user" "pullapprove" {
  name = "pullapprove"
}

resource "aws_iam_access_key" "pullapprove" {
  user = "${aws_iam_user.pullapprove.name}"
}

resource "aws_iam_user_policy" "pullapprove_iam_policy" {
  name = "pullapprove_iam_policy"
  user = "${aws_iam_user.pullapprove.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "${aws_s3_bucket.pullapprove_storage_bucket.arn}/*"
  }]
}
EOF
}
