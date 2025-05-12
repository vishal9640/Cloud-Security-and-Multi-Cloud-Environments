resource "aws_s3_bucket" "wp_content" {
  bucket = "student-portal-content"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "wp_content_encryption" {
  bucket = aws_s3_bucket.wp_content.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "wp_content_block" {
  bucket                  = aws_s3_bucket.wp_content.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}