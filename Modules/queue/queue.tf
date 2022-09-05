
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
        "ArnEquals": { "aws:SourceArn": "${var.aws_s3_bucketArn}" }
      }
    }
  ]
}
POLICY
}

output "data_queue_Arn"{
  value = aws_sqs_queue.data_queue.arn
}
#"ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket.arn}" }