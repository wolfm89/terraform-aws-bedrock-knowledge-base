# S3 Bucket for data sources
resource "aws_s3_bucket" "data_sources" {
  bucket = "knowledge-base-data-sources-${random_id.suffix.hex}"
}

# Random suffix for S3 bucket
resource "random_id" "suffix" {
  byte_length = 4
}

# Upload data to S3 bucket
resource "aws_s3_object" "data_source" {
  bucket = aws_s3_bucket.data_sources.bucket
  key    = "source1/rag.txt"
  source = "data/rag.txt"
}
