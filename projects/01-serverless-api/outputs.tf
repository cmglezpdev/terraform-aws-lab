output "function_name" {
  description = "create-link function name"
  # value       = aws_lambda_function.fn["create-link"].function_name
  value = { for k, fn in aws_lambda_function.fn : k => fn.function_name }
  type  = map(string)
}

output "log_group_name" {
  description = "create-link log group name"
  # value       = aws_cloudwatch_log_group.fn["create-link"].name
  value = { for k, fn in aws_cloudwatch_log_group.fn : k => fn.name }
  type  = map(string)
}

output "table_name" {
  description = "links table name"
  value       = aws_dynamodb_table.links.name
  type        = string
}

output "http_api_url" {
  description = "public base URL of the HTTP API"
  value       = aws_apigatewayv2_api.shortener.api_endpoint
  type        = string
}