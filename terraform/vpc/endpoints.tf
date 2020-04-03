resource "aws_security_group" "endpoint_security_group" {
  name        = "endpoint_security_group"
  description = "Endpoint Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {}
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    # HTTP 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "dynamo_endpoint" {
  vpc_id            = "${aws_vpc.main.id}"
  service_name      = "com.amazonaws.${REGION}.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_security_group.endpoint_security_group.id}",
  ]

  private_dns_enabled = true
}