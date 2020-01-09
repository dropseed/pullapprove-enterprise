resource "aws_s3_bucket" "pullapprove_storage_bucket" {
  bucket = "pullapprove-storage${var.aws_unique_suffix}"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  lifecycle_rule {
    id      = "reports"
    prefix  = "reports/"
    enabled = true
    expiration {
      days = 60
    }
  }
}

resource "aws_s3_bucket" "pullapprove_public_bucket" {
  bucket = "pullapprove-public${var.aws_unique_suffix}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "null_resource" "pullapprove_public_bucket_sync" {
  triggers = {
    source_code_hash = filebase64sha256("${var.assets_dir}/pullapprove_public.zip")
  }
  provisioner "local-exec" {
    command = "unzip ${var.assets_dir}/pullapprove_public.zip -d ${var.assets_dir}/pullapprove_public && aws s3 sync --acl public-read --delete ${var.assets_dir}/pullapprove_public/* s3://${aws_s3_bucket.pullapprove_public_bucket.id} && rm -r ${var.assets_dir}/pullapprove_public"
    environment = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key
      AWS_SECRET_ACCESS_KEY = var.aws_secret_key
      AWS_REGION            = var.aws_region
    }
  }
}

output "pullapprove_public_url" {
  value = "http://${aws_s3_bucket.pullapprove_public_bucket.website_endpoint}"
}
