# ---------------------------------------------------------------
# 1. Un alias para la cuenta.
#    Sin alias, la URL de acceso a la consola para usuarios IAM es
#    https://999999999999.signin.aws.amazon.com/console. Con alias es
#    https://TU-ALIAS.signin.aws.amazon.com/console.
#    OJO: el alias es único en TODO AWS. Si está cogido, el apply falla.
# ---------------------------------------------------------------

variable "account_alias" {
  description = "Alias for the AWS account"
  type        = string
}

resource "aws_iam_account_alias" "this" {
  account_alias = var.account_alias
}

# ---------------------------------------------------------------
# 2. El usuario. Sin claves de acceso: no vas a crear ninguna.
#    force_destroy permite destruirlo aunque tenga credenciales
#    creadas fuera de Terraform.
# ---------------------------------------------------------------
resource "aws_iam_user" "terraform" {
  name          = "terraform"
  force_destroy = true
}


# ---------------------------------------------------------------
# 3. Contraseña de consola. La necesitas porque `aws login` usa
#    justamente tus credenciales de consola para emitir credenciales
#    temporales. password_reset_required la convierte en una
#    contraseña de un solo uso: la cambias al entrar.
# ---------------------------------------------------------------
resource "aws_iam_user_login_profile" "terraform" {
  user                    = aws_iam_user.terraform.name
  password_length         = 32
  password_reset_required = true
}

output "terraform_user_password" {
  description = "Password for the terraform user"
  value       = aws_iam_user_login_profile.terraform.password
  type        = string
  sensitive   = true
}

output "console_signin_url" {
  description = "URL to sign in to the AWS console"
  value       = "https://${var.account_alias}.signin.aws.amazon.com/console"
  type        = string
}

data "aws_iam_policy_document" "terraform_course" {
  statement {
    sid = "CourseServices"
    actions = [
      "budgets:*",
      "sns:*",
      "iam:*",
      "lambda:*",
      "logs:*",
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    sid       = "StateObject"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.state.arn}/*/terraform.tfstate"]
  }

  statement {
    sid       = "StateLockObject"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.state.arn}/*/terraform.tfstate.tflock"]
  }
}

resource "aws_iam_policy" "terraform_course" {
  name        = "terraform-course"
  description = "Policy for the terraform course"
  policy      = data.aws_iam_policy_document.terraform_course.json
}

resource "aws_iam_user_policy_attachment" "terraform_course" {
  user       = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.terraform_course.arn
}

# ---------------------------------------------------------------
# 5. Y el permiso para que `aws login` pueda emitir credenciales
#    a este usuario. Sin esto el login falla, y el error no dice
#    de forma evidente que le falta esta política.
#    Root no la necesita: root no necesita ninguna política.
# ---------------------------------------------------------------
resource "aws_iam_user_policy_attachment" "signin" {
  user       = aws_iam_user.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/SignInLocalDevelopmentAccess"
}