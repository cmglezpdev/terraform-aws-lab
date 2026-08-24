# 00 · Foundations

La base de la cuenta. Es el único stack del repositorio que **no se destruye**: cuesta cero
y protege todo lo demás.

## Qué construye

| Recurso | Para qué |
|---|---|
| `aws_budgets_budget` | Presupuesto mensual con alarmas por correo: gasto real y gasto **proyectado** |
| `aws_sns_topic` + política | Canal de alertas al que publica Budgets, probado de verdad en la lección 02 |
| `aws_s3_bucket` de state | Backend remoto del curso entero: versionado, privado y con bloqueo nativo |
| *(lección 04)* usuario IAM `terraform` | Sustituye a las credenciales root para todo el curso |

## Coste

**0,00 USD.** AWS Budgets ofrece los dos primeros presupuestos sin coste, SNS no cobra por un
topic en reposo, y S3 con unos pocos kilobytes de state cuesta del orden de 0,0000002 USD al
mes. Mil `apply` costarían alrededor de un céntimo en peticiones.

## Decisiones de diseño

**El correo de alerta es una variable, no una constante.** Este repositorio es público. El
valor real vive en `terraform.tfvars`, que está en `.gitignore`.

**Dos notificaciones, no una.** `ACTUAL` al 50% avisa de que el mes va caro; `FORECASTED` al
100% avisa de que, al ritmo actual, se pasará del techo a fin de mes. La segunda es la que
detecta un NAT Gateway olvidado el mismo día en que se olvidó.

**El bucket del state guarda su propio state, y está bien.** Se crea en este mismo stack con
state local y luego se migra dentro con `terraform init -migrate-state`. La alternativa —un
stack `bootstrap/` aparte— deja un state local vivo para siempre en un rincón del repositorio;
es lo correcto en una organización con muchas cuentas, y desproporcionado aquí.

**El bucket lleva `prevent_destroy = true`.** Un `terraform destroy` de este stack borraría el
bucket que contiene su propio state. Es deliberadamente incómodo: para desmontarlo de verdad
hay que editar el código primero.

**No hay recurso de cifrado, y es a propósito.** Desde el 5 de enero de 2023 S3 cifra con
AES-256 todos los objetos nuevos, gratis y sin poder desactivarlo. El
`aws_s3_bucket_public_access_block` sí se declara, aunque también sea el valor por defecto,
porque sobre lo que Terraform no gestiona no hay `plan` que detecte *drift*.

**Bloqueo nativo de S3, no DynamoDB.** `use_lockfile = true` es GA desde Terraform 1.11.0
(febrero de 2025), y en ese mismo cambio HashiCorp deprecó los argumentos de DynamoDB. Casi
todo el material que circula por internet sigue enseñando la tabla.

**Un presupuesto de AWS notifica, no corta.** Frenar el gasto automáticamente requeriría
EventBridge más una Lambda con permisos destructivos, y eso en una cuenta de aprendizaje hace
más daño que bien. La alarma es suficiente porque el modelo operativo es destruir al terminar
cada sesión.

## Uso

```bash
export AWS_PROFILE=personal
aws sts get-caller-identity      # debe salir la cuenta 999999999999

cp terraform.tfvars.example terraform.tfvars   # pon tu correo
terraform init
terraform plan
terraform apply
```

El state vive en S3. Un clon nuevo de este repositorio solo necesita `terraform init`: el
backend está declarado en `backend.tf`.

No ejecutes `terraform destroy` en este stack. `prevent_destroy` sobre el bucket lo impide de
todas formas.

## Lecciones asociadas

- [Lección 01 — El primer `apply` que no es de juguete](../../lessons/0001-el-primer-apply.html)
- [Lección 02 — Haz que la alarma suene de verdad](../../lessons/0002-haz-que-la-alarma-suene.html)
- [Lección 03 — Saca el state de tu portátil](../../lessons/0003-saca-el-state-de-tu-portatil.html)
