# Referencias

Documentos de consulta rápida, pensados para reconsultar e imprimir. A diferencia de las
lecciones —que se leen una vez—, esto es lo que vuelves a abrir seis meses después.

## Terraform

| Documento | Qué contiene |
|---|---|
| [terraform-cli.html](./terraform-cli.html) | Comandos, símbolos del plan, bloques del lenguaje, meta-argumentos, backend S3, y qué hacer cuando algo falla |
| [terraform-refactor.html](./terraform-refactor.html) | La dirección como identidad, `for_each` y sus trampas, bloques `moved` vs `state mv`, y la receta de seis pasos del refactor invisible |

## Cadena de herramientas

| Documento | Qué contiene |
|---|---|
| [typescript-lambda.html](./typescript-lambda.html) | Las tres capas y la pregunta que las decide, *parse don't validate*, tamaños medidos del artefacto, dónde meter una dependencia (bundle / layer / runtime), tests con `node --test` sin dependencias, y qué prueba cada nivel |

## Servicios AWS

Un fichero por servicio. Cada uno responde las mismas ocho preguntas: qué es, para qué se
usa, qué tipos hay, cómo funciona por dentro, cuánto cuesta, qué límites tiene, cuándo NO
usarlo, y cómo se escribe en Terraform. Todos terminan con preguntas de comprobación.

| Servicio | Modelo de coste | Proyectos |
|---|---|---|
| [AWS Budgets](./aws-budgets.html) | Gratis sin acciones | 00 |
| [Amazon SNS](./aws-sns.html) | Por uso, cero en reposo | 00, 02 |
| [Amazon S3](./aws-s3.html) | Por uso, cero en reposo | 00, 02, 05, 07 |
| [AWS IAM](./aws-iam.html) | Gratis, siempre | 00 y todos los demás |
| [AWS Lambda](./aws-lambda.html) | Por uso, cero en reposo | 01, 02, 03 |
| [Amazon DynamoDB](./aws-dynamodb.html) | Por uso, cero en reposo | 01, 02, 03 |
| [Amazon API Gateway](./aws-apigateway.html) | Por uso, cero en reposo | 01, 03 |

La ficha de Lambda incluye además [las dos capacidades de *Custom settings*](./aws-lambda.html#capacidades-2026)
—*durable execution* y *EC2 capacity provider*— y por qué ninguna encaja en este curso.

_Pendientes: SQS, EventBridge, VPC, ALB, RDS, CloudFront, Bedrock, EKS._

## Cómo se generan

Con el skill [`aws-service-explainer`](../.claude/skills/aws-service-explainer/SKILL.md), que
fija la estructura, exige verificar cada cifra contra la documentación de AWS o la Price List
API, y prohíbe escribir precios de memoria.
