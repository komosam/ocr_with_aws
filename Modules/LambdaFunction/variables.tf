variable "queue_arn" {
  description = "arn of the queu"
  type = string
}

variable "path_to_roles" {
  description = "absolute path to variables"
  type = string
  default = "/Users/komo/Documents/MLOPS/aws_lab1/ocr_aws_2/ocr_with_aws/Modules/LambdaFunction"
}