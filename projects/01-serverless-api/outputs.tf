output "function_name" {
  description = "create_link function name"
  value       = aws_lambda_function.create_link.function_name
  type        = string
}

output "log_group_name" {
  description = "create_link log group name"
  value       = aws_cloudwatch_log_group.create_link.name
  type        = string
}

output "table_name" {
  description = "links table name"
  value       = aws_dynamodb_table.links.name
  type        = string
}
