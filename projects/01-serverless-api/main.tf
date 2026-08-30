locals {
  name = "url-shortener"

  # Una entrada por función. La clave trabaja triple: es el nombre del bundle
  # (app/dist/<clave>.mjs), el sufijo del function_name y la dirección en el state.
  functions = {
    "create-link" = {
      route_key     = "POST /links"
      table_policy  = "put-links"
      table_sid     = "PutLinks"
      table_actions = ["dynamodb:PutItem"]
    }

    "get-link" = {
      route_key     = "GET /{code}"
      table_policy  = "read-links"
      table_sid     = "ReadLinks"
      table_actions = ["dynamodb:GetItem"]
    }
  }


  # create-link_function_name = "${local.name}-create-link"
  # get-link_function_name    = "${local.name}-get-link"
}
