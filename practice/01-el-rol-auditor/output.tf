output "role_name" {
  value = aws_iam_role.auditor.name
  description = "The name of the auditor role"
  type = string
}

output "role_arn" {
  value = aws_iam_role.auditor.arn
  description = "The ARN of the auditor role"
  type = string
}

output "aws_assume_role_policy" {
  value = "aws sts assume-role --role-arn ${aws_iam_role.auditor.arn} --role-session-name audit --profile personal"
  description = "The AWS CLI command to assume the auditor role"
  type = string
}