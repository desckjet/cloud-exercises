locals {
  artifact_bucket_suffix = try(random_string.artifact_suffix[0].result, "")
  bucket_name            = var.artifact_bucket_name != "" ? var.artifact_bucket_name : "${var.name_prefix}-artifacts-${local.artifact_bucket_suffix}"
}

resource "random_string" "artifact_suffix" {
  count   = var.artifact_bucket_name == "" ? 1 : 0
  length  = 6
  upper   = false
  special = false
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = local.bucket_name
  force_destroy = var.artifact_bucket_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
