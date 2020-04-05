resource "aws_security_group" "endpoint_security_group" {
  name        = "endpoint_security_group"
  description = "Endpoint Security Group"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ingress_https" {
  security_group_id        = aws_security_group.endpoint_security_group.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.use_endpoint_security_group.id
}

resource "aws_security_group_rule" "ingress_http" {
  security_group_id        = aws_security_group.endpoint_security_group.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.use_endpoint_security_group.id
}

resource "aws_security_group" "use_endpoint_security_group" {
  name        = "use_endpoint_security_group"
  description = "Security Group that allows use of VPC endpoints"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "egress_dynamo" {
  security_group_id = aws_security_group.use_endpoint_security_group.id
  description = "DynamoDB service"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks      = data.aws_prefix_list.dynamo.cidr_blocks
}

resource "aws_security_group_rule" "egress_https" {
  security_group_id        = aws_security_group.use_endpoint_security_group.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.endpoint_security_group.id
}

resource "aws_security_group_rule" "egress_http" {
  security_group_id        = aws_security_group.use_endpoint_security_group.id
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.endpoint_security_group.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = [aws_route_table.private_route_table.id]

  // note that for gateway endpoints (such as dynamo db, we cannot lock down the principle; see https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints-access.html#vpc-endpoint-policies)
  policy          = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
            "dynamodb:DeleteItem",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:UpdateItem",
            "dynamodb:BatchWriteItem"              
          ],
          "Resource":  [ 
            "${var.dynamo_config.participant_table.arn}",
            "${var.dynamo_config.wheel_table.arn}"
          ]
        }
    ]
}
POLICY
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [aws_route_table.private_route_table.id]

  // note that for gateway endpoints (such as dynamo db, we cannot lock down the principle; see https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints-access.html#vpc-endpoint-policies)
  policy          = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
            "s3:GetObject"            
          ],
          "Resource": "${var.s3_config.static_bucket.arn}/*"
        }
    ]
}
POLICY
}

resource "aws_vpc_endpoint" "execute_api" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.endpoint_security_group.id
  ]

  private_dns_enabled = true  
}