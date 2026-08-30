# El libro de mudanzas: cada bloque le cuenta a Terraform que un objeto que ya
# existe en AWS cambió de dirección en el código. Sin esto, el plan propondría
# destruirlo todo y recrearlo.

# IAM Role for lambda
moved {
  from = aws_iam_role.create_link
  to   = aws_iam_role.fn["create-link"]
}

moved {
  from = aws_iam_role.get_link
  to   = aws_iam_role.fn["get-link"]
}


# CloudWatch log groups
moved {
  from = aws_cloudwatch_log_group.create_link
  to   = aws_cloudwatch_log_group.fn["create-link"]
}

moved {
  from = aws_cloudwatch_log_group.get_link
  to   = aws_cloudwatch_log_group.fn["get-link"]
}

# IAM Role Policy For logs

moved {
  from = aws_iam_role_policy.create_link_logs
  to   = aws_iam_role_policy.logs["create-link"]
}

moved {
  from = aws_iam_role_policy.get_link_logs
  to   = aws_iam_role_policy.logs["get-link"]
}

# IAM Role Policy for DynamoDB

moved {
  from = aws_iam_role_policy.create_link_put
  to   = aws_iam_role_policy.table["create-link"]
}

moved {
  from = aws_iam_role_policy.get_link_read
  to   = aws_iam_role_policy.table["get-link"]
}

# Lambda functions

moved {
  from = aws_lambda_function.create_link
  to   = aws_lambda_function.fn["create-link"]
}

moved {
  from = aws_lambda_function.get_link
  to   = aws_lambda_function.fn["get-link"]
}

# Api Gateway plugins

moved {
  from = aws_apigatewayv2_integration.create_link
  to   = aws_apigatewayv2_integration.fn["create-link"]
}

moved {
  from = aws_apigatewayv2_integration.get_link
  to   = aws_apigatewayv2_integration.fn["get-link"]
}

# Api Gateway Routes

moved {
  from = aws_apigatewayv2_route.create_link
  to   = aws_apigatewayv2_route.fn["create-link"]
}

moved {
  from = aws_apigatewayv2_route.get_link
  to   = aws_apigatewayv2_route.fn["get-link"]
}

# Api Gateway (Lambda permissions)

moved {
  from = aws_lambda_permission.http_api_create_link
  to   = aws_lambda_permission.fn["create-link"]
}

moved {
  from = aws_lambda_permission.http_api_get_link
  to   = aws_lambda_permission.fn["get-link"]
}
