# Todo lo que ES la función get_link: identidad, logs, la llave de lectura,
# el artefacto y la función. Gemela de create-link.tf — y que se note:
# esta duplicación es deliberada, y la lección 10 la funde sin destruir nada.

# --- Identidad: quién puede ponerse el uniforme -----------------


resource "aws_iam_role" "get_link" {
  name               = local.get_link_function_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# --- Logs: el grupo y la llave para escribir en él --------------

resource "aws_cloudwatch_log_group" "get_link" {
  name              = "/aws/lambda/${local.get_link_function_name}"
  retention_in_days = 7
}

data "aws_iam_policy_document" "get_link_logs" {
  statement {
    sid       = "WriteOwnLogs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.get_link.arn}:*"]
  }
}

resource "aws_iam_role_policy" "get_link_logs" {
  name   = "write-own-logs"
  role   = aws_iam_role.get_link.id
  policy = data.aws_iam_policy_document.get_link_logs.json
}

# --- Datos: la llave para LEER de la tabla — y solo leer --------

data "aws_iam_policy_document" "get_link_read" {
  statement {
    sid       = "ReadLinks"
    actions   = ["dynamodb:GetItem"]
    resources = [aws_dynamodb_table.links.arn]
  }
}

resource "aws_iam_role_policy" "get_link_read" {
  name   = "read-links"
  role   = aws_iam_role.get_link.id
  policy = data.aws_iam_policy_document.get_link_read.json
}


# Artifact and function
data "archive_file" "get_link" {
  type        = "zip"
  source_file = "${path.module}/app/dist/get-link.mjs"
  output_path = "${path.module}/build/get-link.zip"
}

resource "aws_lambda_function" "get_link" {
  function_name = local.get_link_function_name
  role          = aws_iam_role.get_link.arn

  runtime       = "nodejs24.x"
  handler       = "get-link.handler"
  architectures = ["arm64"]

  filename         = data.archive_file.get_link.output_path
  source_code_hash = data.archive_file.get_link.output_base64sha256

  memory_size = 128
  timeout     = 5

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.links.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.get_link,
    aws_iam_role_policy.get_link_logs,
    aws_iam_role_policy.get_link_read
  ]
}