
resource "aws_sqs_queue" "lambda_retry_queue" {
  name = "lambda-retry-queue"
}


data "aws_iam_policy_document" "lambda_retry_queue_document" {
  statement {
    sid = "SendFailureRecordsToQueue"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.lambda_retry_queue.arn]
  }
}

resource "aws_iam_role_policy" "lambda_retry_queue_policy" {
  name   = "lambda-retry-queue-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_retry_queue_document.json
}