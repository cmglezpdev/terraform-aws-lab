# Data Sources to get the current caller identity and the IAM policy document
data "aws_caller_identity" "current" {
}

# IAM Policy Document for Read Only Access to Lambda and DynamoDB
data "aws_iam_policy_document" "read_only_policy" {
  statement {
    sid = "ReadOnlyPolicy"

    actions = [
      "lambda:ListFunctions",
      "lambda:GetFunctionConfiguration",

      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
    ]

    resources = ["*"]
  }
}

# IAM Policy Document for Assume Role Policy
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "AssumeRolePolicy"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"]
    }
  }
}


# Create the IAM role for the auditor
resource "aws_iam_role" "auditor" {
  name               = "practice-01-auditor"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


# Assign the identity policy to the auditor role
resource "aws_iam_role_policy" "read_only_policy" {
  name   = "read_only_policy"
  policy = data.aws_iam_policy_document.read_only_policy.json
  role   = aws_iam_role.auditor.id
}