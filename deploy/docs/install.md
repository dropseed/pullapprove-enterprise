# Install

Make sure you have the following things installed or set up and ready to go.

- git
- an AWS account
- [Terraform](https://www.terraform.io/downloads.html)

## Clone this repo

You will most likely want to maintain a clone/fork of this repo to streamline the process updating to new versions.

```sh
$ git clone https://github.com/dropseed/pullapprove pullapprove-yourcompany
$ git remote rename origin upstream
# Create a new, private and empty git repo that you can push this to
$ git remote add origin <your repo url>
$ git push --set-upstream origin
```

## Create a "PullApprove" GitHub App in GHE

You will need to create an internal GitHub App within your GitHub Enterprise
installation.

- The name can be "PullApprove Enterprise", or "PullApprove Enterprise (yourcompany)" if you're using GitHub.com.
- The homepage and authorization callback URL are not used yet in PullApprove Enterprise. You might just set them to `https://www.pullapprove.com` to point users towards the PullApprove documentation.
- The webhook URL will be created *after* you run Terraform. So for now you just need to use a placeholder (ex. `https://yourcompany.com`).
- You *should* create a webhook secret (ex. output of `ruby -rsecurerandom -e 'puts SecureRandom.hex(20)'`).

See [this screenshot](img/github-app-settings.png) for an easy view of
which permissions and events should be enabled.

After the app has been created, you will need to click "generate private key"
and save that file for the next step.

You can use [this image](img/github-app-logo.png) for the app logo/avatar.

## Set up Terraform variables

There are a handful of required and optional settings. Some of the settings will
need to be copied from your new GitHub App details. The full list of settings
can be found in [variables.tf](aws/variables.tf). An easy way to configure your
settings is to create `aws/terraform.tfvars` that looks like this:

```hcl
aws_region = "(an AWS region)"
aws_access_key = "(an AWS access key)"
aws_secret_key = "(an AWS secret key)"
aws_bucket_suffix = "-yourcompany"
github_api_base_url = "https://github.yourcompany.com/api/v3"
github_app_id = "(GitHub App ID from the previous step)"
github_app_webhook_secret = "(webhook secret from the previous step)"
github_app_private_key = "(base64 encoded private key from the previous step -- ex. `cat private-key.pem | base64`)"
github_bot_name = "(slugified name of your GitHub App + [bot], ex. `pullapprove-enterprise[bot]`)"
```

> Note: If you are installing this to run on GitHub.com then you should also set `github_status_context` to something other than "pullapprove" (like "pullapprove-yourcompany"), so that it doesn't use the same commit status name as our hosted service.

## Download the PullApprove zip files

Terraform will expect these zip files:

- `./versions/3.7.0/pullapprove_webhook_aws.zip`
- `./versions/3.7.0/pullapprove_worker_aws.zip`
- `./versions/3.7.0/pullapprove_public.zip`

These currently contain proprietary code,
and you will need to get them from us.
Do not redistribute or share these files.

## Run terraform

```sh
$ cd aws
$ terraform init
$ terraform apply
```

## Update GitHub App

If everything ran correctly, you should see a webhook URL at the end of the
Terraform output. Unless you are going to set up a custom domain, you can now
point your GitHub App directly to this webhook. It will not be visible to users,
and is secured with the webhook secret that you created.

Go back to your GitHub App and paste your new webhook URL in the settings and
hit save.

Under the "Advanced" tab of your GitHub App, you will be able to see recent
webhook deliveries. There should be a "ping" event from before that failed
because the webhook wasn't set up. You can click "Redeliver" and you should get
a 200 (successful) response.

## That's all!

PullApprove Enterprise should now be set up to work with your GitHub Enterprise
installation. You can install the app on some repositories, and test it out. The
"Advanced" tab of your GitHub App will always have the webhook
requests/responses which can be useful for debugging. You will also have logs
for the PullApprove webhook and worker functions that you can inspect.

Error reporting can be configured through any services provided by your host, or
you can use the `sentry_dsn` Terraform variable to automatically send webhook
and worker errors to [Sentry](https://sentry.io). If you want to send errors
directly to *us*, then we can give you a SENTRY_DSN to use (note: this will also
send any relevant data our way).

You'll most likely want to save your `terraform.tfvars` and `terraform.tfstate`
somewhere. Your organization will probably have a preference regarding how to do
this. *If* you want to store them in git repo itself, then you will need
to remove them from `.gitignore`.

If you have any questions, just let us know.
