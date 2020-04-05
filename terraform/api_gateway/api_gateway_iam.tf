resource "aws_iam_role" "api_gateway_role" {
  name = "AWSOpsWheelApiGatewayRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api_gateway_policy" {
  name = "AWSOpsWheelApiGatewayPolicy"
  role = aws_iam_role.api_gateway_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "${var.s3_config.static_bucket.arn}/*"
        },
        {
          "Sid": "AllowAccessThroughEndpointOnly",
          "Action": "s3:*",
          "Effect": "Deny",
          "Resource": "*",
          "Condition": { "StringNotEquals" : { "aws:sourceVpce": "${var.vpc_config.s3_vpc_endpoint.id}" } }
        }  
    ]
}
  EOF
}