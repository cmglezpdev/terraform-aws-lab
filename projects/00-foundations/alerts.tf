# used to get the current account ID
data "aws_caller_identity" "current" {}

# create an SNS topic to receive alerts
resource "aws_sns_topic" "alerts" {
  name = "course-terraform-alerts"
}

# subscribe an email to the topic
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# create a policy to allow the Budgets service to publish to the topic
data "aws_iam_policy_document" "allow_budgets" {
  statement {
    sid     = "AWSBudgetsSNSPublishingPermissions"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    resources = [aws_sns_topic.alerts.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:budgets::${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

# apply the policy to the topic
resource "aws_sns_topic_policy" "alerts" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.allow_budgets.json
}

# output the ARN of the alerts topic
output "alerts_topic_arn" {
  description = "ARN of the alerts topic"
  value       = aws_sns_topic.alerts.arn
}