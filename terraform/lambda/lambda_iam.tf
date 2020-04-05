resource "aws_iam_role" "lambda_role" {
  name = "AWSOpsWheelLambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "AWSOpsWheelLambdaPolicy"
  role = aws_iam_role.lambda_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DynamoTableAccess",
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
          ],
          "Effect": "Allow"
        },
        {
          "Sid": "AllowAccessThroughEndpointOnly",
          "Action": "dynamodb:*",
          "Effect": "Deny",
          "Resource": "*",
          "Condition": { "StringNotEquals" : { "aws:sourceVpce": "${var.vpc_config.dynamo_vpc_endpoint.id}" } }
        }  
    ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "basic_lambda_attach" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access_lambda_attach" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}