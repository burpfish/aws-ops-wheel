resource "aws_api_gateway_rest_api" "wheel_api" {
  name = var.api_name
  body = data.template_file.body.rendered

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [ var.vpc_config.api_gateway_vpc_endpoint.id] 
  }

  // Only allow this API to be accessed through our vpc endpoint
  policy = <<EOF
  {

    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "*",
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpc": "${var.vpc_config.api_gateway_vpc_endpoint.id}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "*"
        }
    ]
}
EOF
}

data "template_file" "body" {
  template = file("${path.module}/api_template.yml")
  vars = merge(
    var.lambda_config.lambda_arns,
    {
      region             = data.aws_region.current.name,
      static_bucket_name = var.s3_config.static_bucket.id,
      api_gateway_role   = aws_iam_role.api_gateway_role.arn
    }
  )
}

resource "aws_api_gateway_deployment" "app" {
  rest_api_id       = aws_api_gateway_rest_api.wheel_api.id
  stage_description = md5(file("${path.module}/api_template.yml"))
  stage_name        = "app"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = length(keys(var.lambda_config.lambda_arns))
  statement_id  = "AllowApiGatewayToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = keys(var.lambda_config.lambda_arns)[count.index]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.wheel_api.execution_arn}/*/*/*"
}