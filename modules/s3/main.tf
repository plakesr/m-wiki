resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name

  tags = {
    Name        = var.tags_name
  }
}

resource "aws_s3_bucket_public_access_block" "going_public" {
  bucket = aws_s3_bucket.b.id

  
  block_public_policy = var.block_public_policy
}