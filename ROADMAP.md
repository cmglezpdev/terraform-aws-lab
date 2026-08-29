# Roadmap: 8 proyectos

Cada proyecto vive en `projects/NN-nombre/`, es autocontenido, y sigue el mismo ciclo:
**diseñar → `apply` → probar con `curl`/consola → medir coste → `destroy`**.

Cada proyecto declara en su `README.md`: diagrama, servicios AWS usados, conceptos
Terraform nuevos, coste estimado por hora, y las decisiones de diseño con su porqué.

| # | Proyecto | Qué construyes | AWS | Terraform | Coste/h |
|---|---|---|---|---|---|
| 00 | `00-foundations` | La base de la cuenta: presupuesto con alarma **probada**, usuario para Terraform, backend remoto de state | IAM, Budgets, SNS, S3 | provider, resource, variable, output, backend S3 + `use_lockfile`, migración de state | ~0 USD |
| 01 | `01-serverless-api` | Acortador de URLs: `POST /links` crea, `GET /{code}` redirige 301 | API Gateway HTTP, Lambda, DynamoDB, CloudWatch Logs | locals, `for_each`, `archive_file`, módulo local, IAM least-privilege | ~0 USD |
| 02 | `02-event-driven` | Pipeline asíncrono: subes un CSV a S3 → se procesa → te llega un email | S3, EventBridge, SQS + DLQ, Lambda, SNS, DynamoDB | dependencias implícitas vs `depends_on`, `count` vs `for_each`, data sources | ~0 USD |
| 03 | `03-ai-gateway` | Tu propio "AI Gateway": endpoint que llama a Claude en Bedrock, con caché y rate limiting | Bedrock, Lambda Function URL (streaming), DynamoDB TTL, API Gateway usage plans | `terraform_data`, provisioners, gestión de secretos, límites del IaC | ~0 USD + tokens |
| 04 | `04-vpc-three-tier` | Arquitectura de 3 capas real: ALB público → app privada → base de datos aislada | VPC, subnets, IGW, NAT, SG, ALB, ASG/ECS, RDS, Secrets Manager, SSM | módulos de la registry, `for_each` sobre AZs, `dynamic` blocks | **~0,15 USD/h** |
| 05 | `05-edge-cdn` | Frontend estático global con TLS y caché en el borde | S3, CloudFront + OAC, ACM, Route 53 | providers con `alias` (multi-región), `lifecycle`, dependencias entre regiones | ~0 USD |
| 06 | `06-eks-platform` | El acortador del proyecto 01, pero en Kubernetes | EKS, ECR, ALB Controller, IRSA, node groups | providers `kubernetes` y `helm`, módulos oficiales, IRSA | **~0,25 USD/h** |
| 07 | `07-multi-env-cicd` | Cómo se ve esto en un trabajo: `dev` y `prod` del mismo código, desplegado desde GitHub Actions sin claves | IAM OIDC, S3 | módulos raíz vs hijos, `terraform workspace` vs directorios, `plan` en PR / `apply` en merge | ~0 USD |

## Orden y por qué

`00` es obligatorio primero: sin presupuesto con alarma no despliegas nada, y sin backend
remoto no aprendes lo único que de verdad diferencia a alguien que sabe Terraform.

`01` → `02` → `03` es la rama **serverless**: barata, se puede dejar desplegada sin miedo,
y es donde practicas Terraform sin que la factura te presione.

`04` → `05` → `06` es la rama de **infraestructura clásica**: aquí es donde está el System
Design de verdad (redes, alta disponibilidad, capas de aislamiento) y donde el reloj corre.
Sesiones cronometradas y `destroy` al final, sin excepción.

`07` cierra: coge lo aprendido y lo empaqueta como se hace en una empresa. Es el proyecto
del que más vas a hablar en una entrevista.

## Regla de coste

Antes de cualquier `apply` en `04` y `06`: mira el reloj, y pon una alarma en el móvil.
Los recursos que cobran por hora estén o no en uso son: **NAT Gateway** (~0,045 USD/h),
**ALB** (~0,023 USD/h), **RDS** (~0,017 USD/h en `db.t4g.micro`), **EKS control plane**
(0,10 USD/h), **IPv4 pública** (0,005 USD/h por IP). Todo lo demás en este roadmap es
pago por uso y con tu volumen es prácticamente cero.


## Lecciones publicadas

| # | Lección | Proyecto | Servicios AWS explicados |
|---|---|---|---|
| 01 | [El primer `apply` que no es de juguete](./lessons/0001-el-primer-apply.html) | 00 | [Budgets](./reference/aws-budgets.html) |
| 02 | [Haz que la alarma suene de verdad](./lessons/0002-haz-que-la-alarma-suene.html) | 00 | [SNS](./reference/aws-sns.html) |
| 03 | [Saca el state de tu portátil](./lessons/0003-saca-el-state-de-tu-portatil.html) | 00 | [S3](./reference/aws-s3.html) |
| 04 | [Deja de ser root](./lessons/0004-deja-de-ser-root.html) | 00 | [IAM](./reference/aws-iam.html) |
| 05 | [Tu código, ejecutándose en AWS](./lessons/0005-tu-codigo-en-aws.html) | 01 | [Lambda](./reference/aws-lambda.html), CloudWatch Logs |
| 06 | [El zip no es tu repositorio](./lessons/0006-el-zip-no-es-tu-repositorio.html) | 01 | [Lambda](./reference/aws-lambda.html#capacidades-2026) · [TypeScript en Lambda](./reference/typescript-lambda.html) |
| 07 | [La memoria del acortador](./lessons/0007-la-memoria-del-acortador.html) | 01 | [DynamoDB](./reference/aws-dynamodb.html) |
| 08 | [La puerta pública](./lessons/0008-la-puerta-publica.html) | 01 | [API Gateway](./reference/aws-apigateway.html) |
| 09 | [La segunda función](./lessons/0009-la-segunda-funcion.html) | 01 | — (`GET /{code}`, 301, puerto del consumidor) |
| 10 | _El refactor invisible_ (pendiente) | 01 | — (`for_each`, bloques `moved`, ¿módulo local?) |

La lección 06 se insertó el 2026-08-25, a petición suya, entre el cerebro y la memoria: capas,
una dependencia real (`zod`) y tests. La memoria y la puerta corren un número cada una.
La lección 08 se partió el 2026-08-28: la puerta y el cambio de protocolo del handler llenan
la sesión, así que la segunda Lambda y el `for_each` prometidos pasan a la 09 — la propia
lección lo dice. La 09 (2026-08-29) volvió a partir: el `for_each` necesita que los gemelos
`create-link.tf`/`get-link.tf` existan primero, y fundirlos sin destruir nada (bloques
`moved`) es un tema entero. El proyecto 01 se completa con la 10.
