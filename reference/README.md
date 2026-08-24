# Referencias

Documentos de consulta rápida, pensados para reconsultar e imprimir. A diferencia de las
lecciones —que se leen una vez—, esto es lo que vuelves a abrir seis meses después.

## Terraform

| Documento | Qué contiene |
|---|---|
| [terraform-cli.html](./terraform-cli.html) | Comandos, símbolos del plan, bloques del lenguaje, meta-argumentos, backend S3, y qué hacer cuando algo falla |

## Servicios AWS

Un fichero por servicio. Cada uno responde las mismas ocho preguntas: qué es, para qué se
usa, qué tipos hay, cómo funciona por dentro, cuánto cuesta, qué límites tiene, cuándo NO
usarlo, y cómo se escribe en Terraform. Todos terminan con preguntas de comprobación.

| Servicio | Modelo de coste | Proyectos |
|---|---|---|
| [AWS Budgets](./aws-budgets.html) | Gratis sin acciones | 00 |
| [Amazon SNS](./aws-sns.html) | Por uso, cero en reposo | 00, 02 |
| [Amazon S3](./aws-s3.html) | Por uso, cero en reposo | 00, 02, 05, 07 |

_Pendientes: Lambda, API Gateway, DynamoDB, SQS, EventBridge, VPC, ALB, RDS, CloudFront,
Bedrock, EKS, IAM._

## Cómo se generan

Con el skill [`aws-service-explainer`](../.claude/skills/aws-service-explainer/SKILL.md), que
fija la estructura, exige verificar cada cifra contra la documentación de AWS o la Price List
API, y prohíbe escribir precios de memoria.
