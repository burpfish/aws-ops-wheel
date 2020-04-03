data "aws_region" "current" {}

data "aws_prefix_list" "dynamo" {
  prefix_list_id = "${aws_vpc_endpoint.dynamodb.prefix_list_id}"
}