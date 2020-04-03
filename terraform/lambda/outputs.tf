output lambda_arns {
  value = zipmap(local.lambda_config.*.name, aws_lambda_function.lambda.*.arn)
}