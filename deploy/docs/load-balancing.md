# Load balancing multiple GitHub Apps

Large organizations may run into the rate limits of using a single GitHub App.
It's possible to work around this by creating multiple GitHub Apps and using multiple workers (one per app) to load balance the API requests.

The easiest way to do this is to add additional worker Lambdas to your existing deployment.
They will pull from the same SQS queue,
and will use the GitHub API to determine the GitHub App `installation.id` at runtime (instead of relying on the webhook `installation.id`).

The setup will look roughly like this:

![](https://user-images.githubusercontent.com/649496/217365756-f8de00ac-41d6-4c89-b913-08fde4d10d29.png)

## Primary GitHub App

Your primary app should use the standard PullApprove configuration.
The webhook URL should point to your API Gateway / webhook Lambda function.

## Additional GitHub Apps

Each additional GitHub App will have the same "permissions" as the primary,
but **webhooks will be disabled**.

- [ ] Copy this URL, paste it in your browser and replace `<organization>` with your GitHub organization name

```
https://github.com/organizations/<organization>/settings/apps/new?name=pullapprove-yourorg-N&url=https://www.pullapprove.com&public=false&webhook_active=false&administration=read&statuses=write&checks=read&pull_requests=write&contents=read&members=read
```

- [ ] Replace the "N" in the name with a number (ex. "1")
- [ ] Copy your App ID (ex. 12345) and save it in Terraform variables
- [ ] Click "Generate a private key"
- [ ] Convert the key to base64 (`cat private-key.pem | base64`)
- [ ] Copy the base64 encoded private key and save it in Terraform variables
- [ ] Delete the downloaded private key file

## Terraform

In short, you'll need to add an additional `aws_lambda_function` and `aws_lambda_event_source_mapping` for each additional worker.

One way to do this is with Terraform's `for_each` feature and a variable like this:

```hcl
additional_workers = {
    # Key will be used as aws_unique_suffix
    "-yourorg-worker-1": {
        github_app_id     = "123456"
        github_app_private_key = "1CRUdJTiB...base64"
    },
    "-yourorg-worker-2": {
        github_app_id     = "789123"
        github_app_private_key = "tS1dJTLi...base64"
    },
}
```

An example using a Terraform module for the base configuration:

```hcl
module "pullapprove" {
  source = "git::https://github.com/dropseed/pullapprove-enterprise.git//deploy/aws?ref=master"

  aws_region                = var.aws_region
  aws_access_key            = var.aws_access_key
  aws_secret_key            = var.aws_secret_key
  aws_unique_suffix         = var.aws_unique_suffix
  github_api_base_url       = "https://api.github.com"
  github_app_webhook_secret = var.github_app_webhook_secret
  github_app_id             = var.github_app_id
  github_app_private_key    = var.github_app_private_key
  github_bot_name           = "pullapprove-yourorg[bot]"

  log_level = "DEBUG"

  github_status_context  = "pullapprove-yourorg"
  pullapprove_version    = "latest"
  assets_dir             = "../versions/latest"
}

resource "aws_lambda_function" "pullapprove_additional_worker" {
  for_each = var.additional_workers

  # A unique function name
  function_name = "pullapprove_worker${each.key}"

  # These values should be the same as the primary worker
  filename         = "../versions/latest/pullapprove_worker_aws.zip"
  role             = module.pullapprove.pullapprove_lambda_role.arn
  handler          = "main.aws_sqs_handler"
  source_code_hash = filebase64sha256("../versions/latest/pullapprove_worker_aws.zip")
  runtime          = "python3.8"
  timeout          = 300
  memory_size      = 256

  environment {
    variables = {
      GITHUB_APP_ID               = each.value.github_app_id
      GITHUB_APP_PRIVATE_KEY_NAME = "github_app_private_key${each.key}" # Reference to SSM param name
      # Or set the private key directly
      # GITHUB_APP_PRIVATE_KEY      = each.value.github_app_private_key

      AWS_SSM_PARAMETER_PATH = "/pullapprove${var.aws_unique_suffix}"
      AWS_SQS_NAME           = module.pullapprove.pullapprove_worker_queue.name
      AWS_S3_BUCKET          = module.pullapprove.pullapprove_storage_bucket.bucket
      GITHUB_STATUS_CONTEXT  = "pullapprove-yourorg"
      UI_BASE_URL            = "${module.pullapprove.pullapprove_public_url}/report/"
      LOG_LEVEL              = "DEBUG"

      # If you are using a dedicated reporting app,
      # you need to see these variables too (the reporting private key is in SSM)
      # GITHUB_REPORTING_APP_ID              = var.github_reporting_app_id
      # GITHUB_REPORTING_APP_INSTALLATION_ID = var.github_reporting_app_installation_id
    }
  }
}

# Tell the additional workers to pull from the worker queue
resource "aws_lambda_event_source_mapping" "pullapprove_additional_worker_event_source_mapping" {
  for_each         = var.additional_workers
  batch_size       = 1
  event_source_arn = module.pullapprove.pullapprove_worker_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.pullapprove_additional_worker[each.key].arn
}

# Store the private key in SSM
resource "aws_ssm_parameter" "pullapprove_additional_worker_github_app_private_key" {
  for_each = var.additional_workers
  name     = "/pullapprove${var.aws_unique_suffix}/github_app_private_key${each.key}"
  type     = "SecureString"
  value    = each.value.github_app_private_key
}
```

## Additional notes

- each GitHub App will need to be installed on each repo
- additional workers will not show up in the default CloudWatch dashboard
- you can replicate an entire "PullApprove" (webhook, queue, cache, worker, etc.) and load balance in front if you want more redundancy
  - each webhook will use the same webhook secret from the primary app
  - each worker will automatically authorize itself if it's `GITHUB_APP_ID` does not match the app ID from the webhook
