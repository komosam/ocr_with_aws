locals {
  lambda-zip-location = "outputs/dataextractor.zip"
  
}

data "archive_file" "init" {
  type        = "zip"
  source_dir = "data_extractor"
  output_path = local.lambda-zip-location
}


# create s3#
module creates3 {
  source = "./Modules/s3bucket"
  queue_arn = module.createqueue.data_queue_Arn
}

# create queue
module "createqueue" {
  source = "./Modules/queue"
  aws_s3_bucketArn = module.creates3.aws_s3_bucketArn
}

# create lambda 

module "createlambdamodule" {
  source = "./Modules/LambdaFunction"
  queue_arn = module.createqueue.data_queue_Arn
}
