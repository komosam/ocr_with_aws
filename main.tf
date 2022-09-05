locals {
  lambda-zip-location = "outputs/dataextractor.zip"
  
}

data "archive_file" "init" {
  type        = "zip"
  source_dir = "data_extractor"
  output_path = local.lambda-zip-location
}


resource "aws_lambda_function" "data_extractor_lambda" {
  filename      = local.lambda-zip-location
  function_name = "data_extractor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.helper"
  source_code_hash = filebase64sha256("outputs/dataextractor.zip")
  runtime = "python3.7"
  }

resource "aws_lambda_event_source_mapping" "lambda_dst" {
  event_source_arn = aws_sqs_queue.data_queue.arn
  function_name    = aws_lambda_function.data_extractor_lambda.arn
}

resource "aws_sqs_queue" "data_queue" {
  name                      = "data_queue"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:data_queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket.arn}" }
      }
    }
  ]
}
POLICY
}


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
    queue_arn     = aws_sqs_queue.data_queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}