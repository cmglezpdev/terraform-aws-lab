
output "lambda_function_name" {
  value       = aws_lambda_function.lambda.function_name
  description = "The name of the Lambda function"
}

output "queue_name" {
  value       = aws_sqs_queue.lambda_retry_queue.name
  description = "The name of the SQS queue"
}

output "cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.lambda_log_group.name
  description = "The name of the CloudWatch log group for the Lambda function"
}