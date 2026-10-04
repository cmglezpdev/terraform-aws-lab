
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    sid     = "LambdaServiceCanAssumeRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}


resource "aws_lambda_function" "lambda" {
  role          = aws_iam_role.lambda_role.arn
  function_name = "lambda-retry-sqs"

  handler          = "index.handler"
  runtime          = "nodejs24.x"
  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    aws_iam_role_policy.lambda_logs_policy,
    aws_iam_role_policy.lambda_retry_queue_policy
  ]
}


resource "aws_lambda_function_event_invoke_config" "failure" {
  function_name          = aws_lambda_function.lambda.function_name
  maximum_retry_attempts = 0

  destination_config {
    on_failure {
      destination = aws_sqs_queue.lambda_retry_queue.arn
    }
  }
}