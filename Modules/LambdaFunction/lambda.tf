
### where to zip lambda 
locals {
  lambda-zip-location = "../../dataextractor.zip"
  
}

data "archive_file" "init" {
  type        = "zip"
  source_dir = "data_extractor"
  output_path = local.lambda-zip-location
}



resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = file("${var.path_to_roles}/lambda-policy.json") # at times ./ fails to read
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = file("${var.path_to_roles}/lambda-assume-policy.json")
}

resource "aws_lambda_function" "data_extractor_lambda" {
  filename      = local.lambda-zip-location
  function_name = "data_extractor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.helper"
  #source_code_hash = filebase64sha256("outputs/dataextractor.zip")
  runtime = "python3.7"
  }

# source of the event 
resource "aws_lambda_event_source_mapping" "lambda_dst" {
  event_source_arn = "${var.queue_arn}"
  function_name    = aws_lambda_function.data_extractor_lambda.arn
}

### output to be consumed by other modules
output "dataextractorLambdaArn"{
  value = aws_lambda_function.data_extractor_lambda.arn
}