variable "alert_email" {
  description = "Email that receives budget alerts"
  type        = string
}

variable "monthly_budget_usd" {
  description = "Monthly budget in USD"
  type        = number
  default     = 30
}

resource "aws_budgets_budget" "monthly" {
  name         = "course-terraform-monthly-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"

  dynamic "notification" {
    for_each = [
      { type = "ACTUAL", threshold = 0.1 },
      { type = "ACTUAL", threshold = 50 },
      { type = "ACTUAL", threshold = 90 },
      { type = "FORECASTED", threshold = 100 },
    ]

    content {
      notification_type          = notification.value.type
      threshold                  = notification.value.threshold
      comparison_operator        = "GREATER_THAN"
      threshold_type             = "PERCENTAGE"
      subscriber_email_addresses = [var.alert_email]
      subscriber_sns_topic_arns  = [aws_sns_topic.alerts.arn]
    }
  }

  # # Early notification threshold
  # notification {
  #   notification_type = "ACTUAL"
  #   comparison_operator = "GREATER_THAN"
  #   threshold = 50
  #   threshold_type = "PERCENTAGE"
  #   subscriber_email_addresses = [var.alert_email]
  # }

  # # REAL WARNING: AWS projects that by the end of the month you will exceed 100%.
  # # This is the one that really saves you: it warns you BEFORE you overspend.
  # notification {
  #   notification_type = "FORECASTED"
  #   comparison_operator = "GREATER_THAN"
  #   threshold = 100
  #   threshold_type = "PERCENTAGE"
  #   subscriber_email_addresses = [var.alert_email]
  # }
}


output "budget_console_url" {
  description = "Where you can monitor the budget in the AWS console"
  value       = "https://console.aws.amazon.com/billing/home#/budgets"
}