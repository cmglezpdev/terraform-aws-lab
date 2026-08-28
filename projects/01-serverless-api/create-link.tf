# Todo lo que ES la función create_link: identidad, logs, permisos,
# artefacto y la función. Se lee de arriba abajo como su historia.

# --- Identidad: quién puede ponerse el uniforme -----------------

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

# --- Logs: el grupo y la llave para escribir en él --------------

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

# --- Datos: la llave para escribir en la tabla ------------------

data "aws_iam_policy_document" "create_link_put" {
  statement {
    sid       = "PutLinks"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.links.arn]
  }
}

resource "aws_iam_role_policy" "create_link_put" {
  name   = "put-links"
  role   = aws_iam_role.create_link.id
  policy = data.aws_iam_policy_document.create_link_put.json
}

# --- El artefacto y la función ----------------------------------

data "archive_file" "create_link" {
  type = "zip"
  # source_dir  = "${path.module}/app/dist" # this carries with the source map and it's not needed
  source_file = "${path.module}/app/dist/index.mjs"
  output_path = "${path.module}/build/create_link.zip"
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

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.links.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.create_link,
    aws_iam_role_policy.create_link_logs,
    aws_iam_role_policy.create_link_put
  ]
}
