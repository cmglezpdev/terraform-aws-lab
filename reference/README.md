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

## La plataforma

| Documento | Qué contiene |
|---|---|
| [Fundamentos de AWS](./aws-fundamentos.html) | Todo es una API HTTP regional con IAM delante; regiones/AZ/edge con cifras de 2026, ámbito zonal-regional-global, por qué `us-east-1` es especial, anatomía del ARN campo a campo, control plane vs data plane, precios y data transfer verificados, y la comparación con Azure |

## Servicios AWS

Un fichero por servicio. Cada uno responde las mismas ocho preguntas: qué es, para qué se
usa, qué tipos hay, cómo funciona por dentro, cuánto cuesta, qué límites tiene, cuándo NO
usarlo, y cómo se escribe en Terraform. Todos terminan con preguntas de comprobación.

| Servicio | Modelo de coste | Proyectos |
|---|---|---|
| [AWS Budgets](./aws-budgets.html) | Gratis sin acciones · reports 0,01 USD | 00 |
| [Amazon SNS](./aws-sns.html) | Por uso, cero en reposo · SMS aparte | 00, 02 |
| [Amazon S3](./aws-s3.html) | Por uso, cero en reposo | 00, 02, 05, 07 |
| [AWS IAM](./aws-iam.html) | Gratis (Access Analyzer, en parte de pago) | 00, todos; a fondo en 07 |
| [AWS Lambda](./aws-lambda.html) | Por uso, cero en reposo | 01, 02, 03 |
| [Amazon DynamoDB](./aws-dynamodb.html) | Por uso, cero en reposo (salvo DAX, por hora) | 01, 02, 03 |
| [Amazon API Gateway](./aws-apigateway.html) | Por uso; la caché de REST, por hora | 01, 03 |
| [Amazon CloudWatch](./aws-cloudwatch.html) | Mixto: logs por uso; alarmas y métricas custom por mes | 01 en adelante |
| [Amazon EventBridge](./aws-eventbridge.html) | Por uso, cero en reposo | 02 |
| [Amazon SQS](./aws-sqs.html) | Por uso, cero en reposo | 02 |
| [Amazon Bedrock](./aws-bedrock.html) | Por uso (por token), cero en reposo | 03 |
| [Amazon VPC](./aws-vpc.html) | Gratis la red; NAT, IPv4 y endpoints de interfaz por hora | 04, 06 |
| [Elastic Load Balancing](./aws-elb.html) | Por hora (~0,0325 USD/h reales) + LCU | 04, 06 |
| [Amazon ECS](./aws-ecs.html) | Fargate por segundo mientras el task corre | 04 |
| [Amazon ECR](./aws-ecr.html) | Por uso (almacenamiento GB-mes) | 04, 06 |
| [Amazon RDS](./aws-rds.html) | Por hora, esté o no en uso | 04 |
| [AWS Secrets Manager](./aws-secretsmanager.html) | 0,40 USD/secreto/mes — no es cero en reposo | 04 |
| [AWS Systems Manager](./aws-ssm.html) | Gratis en lo que usa el curso | 04 |
| [Amazon CloudFront](./aws-cloudfront.html) | Por uso; 1 TB + 10 M req gratis siempre | 05 |
| [AWS Certificate Manager](./aws-acm.html) | Gratis (públicos no exportables) | 05 |
| [Amazon Route 53](./aws-route53.html) | 0,50 USD/mes por hosted zone + por uso | 05 |
| [Amazon EKS](./aws-eks.html) | Por hora — 0,10 USD/h el cluster vacío | 06 |

La ficha de Lambda incluye además [las dos capacidades de *Custom settings*](./aws-lambda.html#capacidades-2026)
—*durable execution* y *EC2 capacity provider*— y por qué ninguna encaja en este curso.

Las fichas de servicios aún no tocados en las lecciones (proyectos 03-07) se escribieron y
verificaron el **2026-08-30**; cada cifra lleva su fecha de verificación dentro del documento.

## Cómo se generan

Con el skill [`aws-service-explainer`](../.claude/skills/aws-service-explainer/SKILL.md), que
fija la estructura, exige verificar cada cifra contra la documentación de AWS o la Price List
API, y prohíbe escribir precios de memoria.
