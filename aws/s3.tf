resource "aws_s3_bucket" "pullapprove_storage_bucket" {
  bucket = "pullapprove-storage${var.aws_bucket_suffix}"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  lifecycle_rule {
    id = "reports"
    prefix = "reports/"
    enabled = true
    expiration {
      days = 60
    }
  }
}

resource "aws_s3_bucket" "pullapprove_public_bucket" {
  bucket = "pullapprove-public${var.aws_bucket_suffix}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "null_resource" "pullapprove_public_bucket_sync" {
  triggers = {
    source_code_hash = "${base64sha256(file("${dirname(path.module)}/pullapprove_public.zip"))}"
  }
  provisioner "local-exec" {
    command = "unzip ${dirname(path.module)}/pullapprove_public.zip -d ${dirname(path.module)}/pullapprove_public && aws s3 sync --acl public-read --delete ${dirname(path.module)}/pullapprove_public/* s3://${aws_s3_bucket.pullapprove_public_bucket.id} && rm -r ${dirname(path.module)}/pullapprove_public"
    environment = {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_REGION = "${var.aws_region}"
    }
  }
}

output "pullapprove_report_url" {
  value = "http://${aws_s3_bucket.pullapprove_public_bucket.website_endpoint}/report/"
}
