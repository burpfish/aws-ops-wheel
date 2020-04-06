output vpc {
  value = aws_vpc.vpc
}

output private_subnet {
  value = aws_subnet.private_subnet
}

output use_endpoint_security_group {
  value = aws_security_group.use_endpoint_security_group
}

output dynamo_vpc_endpoint {
  value = aws_vpc_endpoint.dynamodb
}

output s3_vpc_endpoint {
  value = aws_vpc_endpoint.s3
}

output api_gateway_vpc_endpoint {
  value = aws_vpc_endpoint.execute_api
}