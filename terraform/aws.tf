locals {
  oregon_region = "us-west-2"
}

provider "aws" {
  region = local.oregon_region
}