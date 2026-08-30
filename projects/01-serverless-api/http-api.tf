# The gate
resource "aws_apigatewayv2_api" "shortener" {
  name          = local.name
  protocol_type = "HTTP"
}

# The stage: The gate does not exists until it's published.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.shortener.id
  name        = "$default"
  auto_deploy = true
}

# The plugin: The gate knows how to invoke the function.

resource "aws_apigatewayv2_integration" "fn" {
  for_each = local.functions

  api_id           = aws_apigatewayv2_api.shortener.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.fn[each.key].invoke_arn

  integration_method     = "POST"
  payload_format_version = "2.0"
}

# The route: Which petitions can be made to the gate?

resource "aws_apigatewayv2_route" "fn" {
  for_each = local.functions

  api_id    = aws_apigatewayv2_api.shortener.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.fn[each.key].id}"
}


# The permission: The function can be invoked by the gate.

resource "aws_lambda_permission" "fn" {
  for_each = local.functions

  statement_id  = "AllowInvokeFromHttpApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.shortener.execution_arn}/*/*"
}


