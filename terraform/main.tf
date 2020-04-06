locals {
  api_name = "AWSOpsWheel"
}

module "vpc" {
  source = "./vpc"

  dynamo_config = module.dynamo
  s3_config     = module.S3
}

module "api_gateway" {
  source = "./api_gateway"

  api_name      = local.api_name
  lambda_config = module.lambda
  vpc_config    = module.vpc
  s3_config     = module.S3
}

module "lambda" {
  source = "./lambda"

  dynamo_config = module.dynamo
  vpc_config    = module.vpc
}

module "dynamo" {
  source = "./dynamo"
}

module "S3" {
  source = "./S3"
}

module "ui" {
  source = "./ui"

  s3_config = module.S3
}

module "ec2_test" {
  source = "./ec2_test"

  vpc_config = module.vpc
}