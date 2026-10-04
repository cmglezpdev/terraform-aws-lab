
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/lambda-retry-sqs"
  retention_in_days = 7
}

data "aws_iam_policy_document" "lambda_logs_document" {
  statement {
    sid = "LambdaWriteOwnLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.lambda_log_group.arn}:*"]
  }
}

resource "aws_iam_role_policy" "lambda_logs_policy" {
  name   = "lambda-logs-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_logs_document.json
}