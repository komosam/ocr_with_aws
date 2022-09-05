# s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "komo-sam-bucket"
}


resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

# add notification of s3 to queue also add permission to make sure queue has access to lambda

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id
  queue {
    queue_arn     = "${var.queue_arn}" #aws_sqs_queue.data_queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

output "aws_s3_bucketArn"{
  value = aws_s3_bucket.bucket.arn
}