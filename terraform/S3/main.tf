resource "aws_kms_key" "key" {
  description = "awsopswheelsourcebucket key"
}

resource "aws_s3_bucket" "wheel_source_bucket" {
  bucket_prefix = "awsopswheelsourcebucket-"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}