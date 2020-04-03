output vpc_subnet_arn {
  value = resource aws_vpc.vpc.arn
}

output private_subnet_arn {
  value = aws_subnet.private_subnet.arn
}