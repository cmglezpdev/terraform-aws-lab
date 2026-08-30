# Todo lo que ES una función del acortador: identidad, logs, su llave de la
# tabla, el artefacto y la función. Antes eran dos ficheros gemelos; ahora es
# una sola historia contada una vez, con las diferencias en local.functions.

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

resource "aws_iam_role" "fn" {
  for_each           = local.functions
  name               = "${local.name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# --- Logs: el grupo y la llave para escribir en él --------------

resource "aws_cloudwatch_log_group" "fn" {
  for_each          = local.functions
  name              = "/aws/lambda/${local.name}-${each.key}"
  retention_in_days = 7
}

data "aws_iam_policy_document" "fn_logs" {
  for_each = local.functions

  statement {
    sid       = "WriteOwnLogs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.fn[each.key].arn}:*"]
  }
}

resource "aws_iam_role_policy" "logs" {
  for_each = local.functions

  name   = "write-own-logs"
  role   = aws_iam_role.fn[each.key].id
  policy = data.aws_iam_policy_document.fn_logs[each.key].json
}

# --- Datos: la llave de cada función sobre la tabla -------------

data "aws_iam_policy_document" "fn_table" {
  for_each = local.functions

  statement {
    sid       = each.value.table_sid
    actions   = each.value.table_actions
    resources = [aws_dynamodb_table.links.arn]
  }
}

resource "aws_iam_role_policy" "table" {
  for_each = local.functions

  name   = each.value.table_policy
  role   = aws_iam_role.fn[each.key].id
  policy = data.aws_iam_policy_document.fn_table[each.key].json
}

# --- El artefacto y la función ----------------------------------

data "archive_file" "fn" {
  for_each = local.functions

  type        = "zip"
  source_file = "${path.module}/app/dist/${each.key}.mjs"
  output_path = "${path.module}/build/${each.key}.zip"
}

resource "aws_lambda_function" "fn" {
  for_each = local.functions

  function_name = "${local.name}-${each.key}"
  role          = aws_iam_role.fn[each.key].arn

  runtime       = "nodejs24.x"
  handler       = "${each.key}.handler"
  architectures = ["arm64"]

  filename         = data.archive_file.fn[each.key].output_path
  source_code_hash = data.archive_file.fn[each.key].output_base64sha256

  memory_size = 128
  timeout     = 5

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.links.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.fn,
    aws_iam_role_policy.logs,
    aws_iam_role_policy.table
  ]
}