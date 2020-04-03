module "vpc" {
  source = "./vpc"
}

module "api_gateway" {
  source = "./api_gateway"

  lambda_arns        = module.lambda.lambda_arns
  static_bucket_name = module.S3.static_bucket_name
}

module "lambda" {
  source = "./lambda"

  participant_table = module.dynamo.participant_table
  wheel_table       = module.dynamo.wheel_table
  private_subnet_arn = module.vpc.private_subnet_arn
  allow_vpc_endpoints_security_group = 
}

module "dynamo" {
  source = "./dynamo"
}

module "S3" {
  source = "./S3"
}

module "ui" {
  source = "./ui"

  static_bucket_name = module.S3.static_bucket_name
}