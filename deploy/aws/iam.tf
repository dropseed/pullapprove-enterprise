data "aws_caller_identity" "current" {}

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
  name        = "pullapprove_logging"
  path        = "/"
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
  role       = aws_iam_role.pullapprove_lambda_role.name
  policy_arn = aws_iam_policy.pullapprove_logging_policy.arn
}

# SQS
resource "aws_iam_policy" "pullapprove_sqs_policy" {
  name        = "pullapprove_sqs"
  path        = "/"
  description = "IAM policy for PullApprove SQS access"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [{
         "Effect": "Allow",
         "Action": [
              "sqs:ReceiveMessage",
              "sqs:SendMessage",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes",
              "sqs:GetQueueUrl"
          ],
         "Resource": "${aws_sqs_queue.pullapprove_worker_queue.arn}"
   }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pullapprove_sqs_attachment" {
  role       = aws_iam_role.pullapprove_lambda_role.name
  policy_arn = aws_iam_policy.pullapprove_sqs_policy.arn
}

# SSM
resource "aws_iam_policy" "pullapprove_ssm_policy" {
  name        = "pullapprove_ssm"
  path        = "/"
  description = "IAM policy for PullApprove SSM access"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ssm:GetParametersByPath"
          ],
          "Resource": "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/pullapprove${var.aws_unique_suffix}*"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pullapprove_ssm_attachment" {
  role       = aws_iam_role.pullapprove_lambda_role.name
  policy_arn = aws_iam_policy.pullapprove_ssm_policy.arn
}

# also set up an iam user, so that we can sign urls with a longer expiration
# than we can with a role
resource "aws_iam_user" "pullapprove" {
  name = "pullapprove"
}

resource "aws_iam_access_key" "pullapprove" {
  user = aws_iam_user.pullapprove.name
}

resource "aws_iam_user_policy" "pullapprove_iam_policy" {
  name = "pullapprove_iam_policy"
  user = aws_iam_user.pullapprove.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
        "Effect": "Allow",
        "Action": [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject"
        ],
        "Resource": "${aws_s3_bucket.pullapprove_storage_bucket.arn}/*"
  }]
}
EOF
}
