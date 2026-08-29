locals {
  name                      = "url-shortener"
  create_link_function_name = "${local.name}-create-link"
  get_link_function_name    = "${local.name}-get-link"
}
