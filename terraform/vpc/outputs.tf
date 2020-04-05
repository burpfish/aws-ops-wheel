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