locals {
  name          = "url-shortener"
  function_name = "${local.name}-create-link"
}

data "archive_file" "create_link" {
  type        = "zip"
  source_dir  = "${path.module}/app/dist"
  output_path = "${path.module}/build/create_link.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaServiceCanAssume"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "create_link" {
  name               = local.function_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_cloudwatch_log_group" "create_link" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 7
}

data "aws_iam_policy_document" "create_link_logs" {
  statement {
    sid     = "WriteOwnLogs"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    resources = ["${aws_cloudwatch_log_group.create_link.arn}:*"]
  }
}

resource "aws_iam_role_policy" "create_link_logs" {
  name   = "write-own-logs"
  role   = aws_iam_role.create_link.id
  policy = data.aws_iam_policy_document.create_link_logs.json
}

resource "aws_lambda_function" "create_link" {
  function_name = local.function_name
  role          = aws_iam_role.create_link.arn

  runtime       = "nodejs24.x"
  handler       = "index.handler"
  architectures = ["arm64"]

  filename         = data.archive_file.create_link.output_path
  source_code_hash = data.archive_file.create_link.output_base64sha256

  memory_size = 128
  timeout     = 5

  depends_on = [
    aws_cloudwatch_log_group.create_link,
    aws_iam_role_policy.create_link_logs
  ]
}

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