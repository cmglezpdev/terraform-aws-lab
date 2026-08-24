# Terraform aplicado a AWS

Repositorio de aprendizaje: ocho proyectos de infraestructura en AWS escritos con Terraform,
cada uno con su diagrama, su coste por hora y la justificación de sus decisiones de diseño.

No son ejercicios de un bucket S3. Cada proyecto es una arquitectura con varios servicios,
pensada para desplegarse (`apply`), probarse de verdad y destruirse (`destroy`) dentro de la
misma sesión.

## Proyectos

Ver [ROADMAP.md](./ROADMAP.md) para la tabla completa con servicios, conceptos y costes.

| # | Proyecto | Resumen |
|---|---|---|
| 00 | [`00-foundations`](./projects/00-foundations) | Presupuesto con alarma, usuario IAM para Terraform, backend de state remoto en S3 |
| 01 | `01-serverless-api` | Acortador de URLs con API Gateway, Lambda y DynamoDB |
| 02 | `02-event-driven` | Pipeline asíncrono con S3, EventBridge, SQS + DLQ, Lambda y SNS |
| 03 | `03-ai-gateway` | Endpoint hacia Claude en Bedrock, con caché y rate limiting |
| 04 | `04-vpc-three-tier` | Arquitectura de tres capas: ALB público, app privada, RDS aislada |
| 05 | `05-edge-cdn` | Distribución global con CloudFront, OAC y certificados ACM |
| 06 | `06-eks-platform` | El proyecto 01 sobre EKS, con IRSA y ALB Controller |
| 07 | `07-multi-env-cicd` | `dev` y `prod` del mismo código, desplegado desde GitHub Actions con OIDC |

## Convenciones

- **Terraform** `>= 1.9`, provider **AWS** `~> 6.0`. Bloqueo de state nativo de S3
  (`use_lockfile`), no DynamoDB.
- **TypeScript** para todo el código de aplicación. Bundle con `esbuild`.
- Ningún secreto, correo ni valor de entorno en ficheros versionados. Cada proyecto trae un
  `terraform.tfvars.example`.
- Etiquetas por defecto en todos los recursos: `Project`, `Stack`, `ManagedBy`.

## Cómo usar este repositorio

```bash
export AWS_PROFILE=<tu-perfil>
aws sts get-caller-identity          # comprueba SIEMPRE en qué cuenta estás

cd projects/NN-nombre
cp terraform.tfvars.example terraform.tfvars   # y rellénalo
terraform init
terraform plan
terraform apply
# ... probar ...
terraform destroy
```

## Material de aprendizaje

Este repositorio es también un curso. El material está en:

- [`MISSION.md`](./MISSION.md) — por qué existe esto
- [`ROADMAP.md`](./ROADMAP.md) — los ocho proyectos y su orden
- [`lessons/`](./lessons) — lecciones en HTML, una por sesión
- [`reference/`](./reference/README.md) — chuletas imprimibles y una ficha por servicio AWS
- [`GLOSSARY.md`](./GLOSSARY.md) — vocabulario canónico
- [`RESOURCES.md`](./RESOURCES.md) — fuentes de confianza
