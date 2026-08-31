# Terraform + AWS: Recursos

## Knowledge

### Terraform — fuentes primarias

- [Terraform Language Documentation (HashiCorp)](https://developer.hashicorp.com/terraform/language)
  La referencia canónica del lenguaje HCL: bloques, expresiones, funciones, meta-argumentos.
  Úsala para: cualquier duda de sintaxis. Es la única fuente que nunca está desactualizada.
- [Terraform Style Guide (HashiCorp)](https://developer.hashicorp.com/terraform/language/style)
  Convenciones oficiales de nombres, orden de bloques y estructura de ficheros.
  Úsala para: escribir código que parezca escrito por un profesional, no por un tutorial.
- [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
  Cómo se estructura un módulo de verdad (`main.tf`, `variables.tf`, `outputs.tf`, `modules/`).
  Úsala para: los proyectos 01 en adelante, cuando empecemos a modularizar.
- [Backend Type: s3](https://developer.hashicorp.com/terraform/language/backend/s3)
  Configuración del backend remoto. **Ojo**: `use_lockfile = true` es lo actual; el locking
  con DynamoDB está deprecado. Úsala para: el proyecto 00.
- [State: Locking](https://developer.hashicorp.com/terraform/language/state/locking)
  Qué es un lock, por qué existe, y `terraform force-unlock` cuando algo se queda colgado.
- [Terraform AWS Provider — Registry Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
  Documentación de cada `resource` y `data source` de AWS, con ejemplos.
  Úsala para: **siempre**. Antes de escribir cualquier recurso AWS, busca aquí sus argumentos.

### Terraform — libro y práctica

- [Libro: _Terraform: Up & Running_ (3ª ed.), Yevgeniy Brikman — O'Reilly](https://www.terraformupandrunning.com/)
  El libro de referencia del ecosistema, escrito por el cofundador de Gruntwork. Cubre state,
  módulos, secretos, testing y multi-provider con opinión fuerte y justificada.
  Úsalo para: entender el *porqué* de los patrones, no solo el cómo. Capítulos 3 (state) y
  4 (módulos) son los que más te van a servir en entrevistas.
- [terraform-aws-modules (GitHub)](https://github.com/terraform-aws-modules)
  Los módulos comunitarios de facto para VPC, EKS, RDS, ALB. Millones de descargas.
  Úsalos para: los proyectos 04 y 06. Y **léelos por dentro** — son el mejor ejemplo de
  Terraform avanzado que vas a encontrar gratis.

### AWS — Lambda y serverless

- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
  La guía canónica. Tres páginas concretas valen más que el resto juntas:
  [execution environment lifecycle](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html)
  (las fases Init/Invoke/Shutdown, de donde sale todo el rendimiento serverless),
  [Node.js handler](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html)
  (CommonJS vs ESM, estado global, buenas prácticas) y
  [Lambda quotas](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html).
  Úsala para: los proyectos 01, 02 y 03.
- [Deploy transpiled TypeScript code in Lambda with .zip file archives](https://docs.aws.amazon.com/lambda/latest/dg/typescript-package.html)
  La receta oficial de AWS con `esbuild`, sin SAM ni CDK de por medio. Es la base del build
  del proyecto 01. Úsala para: comprobar que tu `package.json` no se ha quedado atrás.
- [Lambda runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html)
  La tabla de identificadores y fechas de deprecación. **Consúltala antes de empezar
  cualquier proyecto nuevo**: un runtime deprecado sigue funcionando pero deja de recibir
  parches, y AWS acaba bloqueando las actualizaciones de la función.
- [AWS Price List API (bulk)](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)
  Los precios reales en JSON, sin credenciales:
  `https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/<Servicio>/current/<región>/index.json`.
  Úsala para: cualquier cifra de coste. Es la única fuente que no envejece en un blog.
- [esbuild](https://esbuild.github.io/getting-started/)
  El bundler del curso. Recuerda que **transpila pero no comprueba tipos**: `tsc --noEmit`
  es un paso aparte y obligatorio.

### AWS

- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)
  Los cinco (ahora seis) pilares con los que AWS juzga una arquitectura.
  Úsalo para: justificar decisiones de diseño en entrevistas. El vocabulario de aquí es
  literalmente el que usan los entrevistadores.
- [AWS Architecture Center](https://aws.amazon.com/architecture/)
  Arquitecturas de referencia por caso de uso, con diagramas oficiales.
  Úsalo para: contrastar tu diseño con el que AWS recomienda antes de construirlo.
- [AWS Pricing Calculator](https://calculator.aws/)
  Úsalo para: estimar el coste **antes** de `apply` en los proyectos 04 y 06.
- [Amazon Bedrock — Model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)
  Cómo habilitar modelos. Los de Anthropic exigen un formulario de primer uso desde consola.
  Úsalo para: el proyecto 03.
- [AWS Free Tier — cambios de julio 2025](https://aws.amazon.com/blogs/aws/aws-free-tier-update-new-customers-can-get-started-and-explore-aws-with-up-to-200-in-credits/)
  Las cuentas creadas desde el 15/07/2025 tienen un modelo distinto (créditos + 6 meses).
  Úsalo para: saber en qué régimen está tu cuenta antes de asumir que algo es gratis.

### AWS — fuentes primarias por servicio

Seleccionadas al escribir las fichas de `reference/` (2026-08-30). Cada ficha cita muchas
más; estas son las que vale la pena leer enteras.

- **Fundamentos**: [ARNs](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html) · [Fault Isolation Boundaries (whitepaper)](https://docs.aws.amazon.com/whitepapers/latest/aws-fault-isolation-boundaries/abstract-and-introduction.html) · [Service endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html) · [Azure for AWS professionals](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/)
- **SQS**: [Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) · [Using Lambda with SQS](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html) · [Fair queues](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-fair-queues.html) — léelas antes de la lección 12
- **CloudWatch**: [Alarms y missing data](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html) · [Log classes](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html) · [Metrics concepts](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html)
- **Bedrock**: [Model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) · [Cross-Region inference](https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html) · [Claude in Amazon Bedrock (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock) · [Pricing](https://aws.amazon.com/bedrock/pricing/)
- **Lambda (ampliación)**: [Response streaming](https://docs.aws.amazon.com/lambda/latest/dg/configuration-response-streaming.html) · [Elegir método de invocación HTTP](https://docs.aws.amazon.com/lambda/latest/dg/furls-http-invoke-decision.html) · [Scaling](https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html) · [Billing del INIT (blog)](https://aws.amazon.com/blogs/compute/aws-lambda-standardizes-billing-for-init-phase/)
- **DynamoDB (ampliación)**: [TTL](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ttl-expired-items.html) · [Global tables](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/V2globaltables_HowItWorks.html) · [Bajada de precio on-demand nov-2024 (blog)](https://aws.amazon.com/blogs/database/new-amazon-dynamodb-lowers-pricing-for-on-demand-throughput-and-global-tables/)
- **API Gateway (ampliación)**: [REST vs HTTP](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html) · [Usage plans](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-usage-plans.html) · [Throttling](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html)
- **SNS (ampliación)**: [Delivery retries](https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html) · [Raw message delivery](https://docs.aws.amazon.com/sns/latest/dg/sns-large-payload-raw-message-delivery.html)
- **EventBridge (ampliación)**: [Operadores de patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html) · [Input transformation](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html) · [Cross-account](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-account.html)
- **VPC**: [Pricing](https://aws.amazon.com/vpc/pricing/) · [Gateway endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html) · [Cargo IPv4 pública (blog)](https://aws.amazon.com/blogs/aws/new-aws-public-ipv4-address-charge-public-ip-insights/) · [NAT regional](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html)
- **ELB**: [ALB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) · [Pricing (LCU)](https://aws.amazon.com/elasticloadbalancing/pricing/) · [Data transfer en NLB (blog)](https://aws.amazon.com/blogs/networking-and-content-delivery/exploring-data-transfer-costs-for-aws-network-load-balancers/)
- **ECS/ECR**: [Task IAM roles](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html) · [Fargate pricing](https://aws.amazon.com/fargate/pricing/) · [ECR VPC endpoints](https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html) · [ECR lifecycle policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)
- **RDS**: [Stop temporarily (la trampa de los 7 días)](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_StopInstance.html) · [Extended Support](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/extended-support.html) · [Multi-AZ DB clusters](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html) · [Aurora Serverless v2 auto-pause](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-auto-pause.html)
- **Secrets Manager**: [Rotation strategies](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotation-strategy.html) · [RDS + Secrets Manager](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html) · [Ephemeral values en Terraform](https://developer.hashicorp.com/terraform/language/manage-sensitive-data/ephemeral)
- **SSM**: [Session Manager prerequisites](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-prerequisites.html) · [Parameter Store throughput](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-throughput.html) · [Pricing](https://aws.amazon.com/systems-manager/pricing/)
- **CloudFront/ACM**: [OAC para S3](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html) · [Functions vs Lambda@Edge](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-choosing.html) · [Pricing pay-as-you-go](https://aws.amazon.com/cloudfront/pricing/pay-as-you-go/) · [Validación DNS de ACM](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html)
- **Route 53**: [ALIAS vs CNAME](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html) · [Health checks (regla del 18 %)](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-determining-health-of-endpoints.html) · [Pricing](https://aws.amazon.com/route53/pricing/)
- **EKS**: [Version lifecycle y extended support](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) · [Pod Identity vs IRSA](https://docs.aws.amazon.com/eks/latest/userguide/service-accounts.html) · [Access entries](https://docs.aws.amazon.com/eks/latest/userguide/grant-k8s-access.html) · [Pricing](https://aws.amazon.com/eks/pricing/)
- **IAM (ampliación)**: [Policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic_policy-eval-denyallow.html) · [Cross-account evaluation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic-cross-account.html) · [Confused deputy](https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html) · [OIDC de GitHub Actions](https://docs.github.com/en/actions/reference/security/oidc) — lectura obligada antes del proyecto 07
- **Budgets (ampliación)**: [Budget actions](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-controls.html) · [Billing alarm de CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html)

### Código de la Lambda: TypeScript, empaquetado y tests

- [Code best practices for TypeScript Lambda functions (AWS)](https://docs.aws.amazon.com/lambda/latest/dg/typescript-handler.html#typescript-best-practices)
  Cuatro viñetas, y la primera lo dice todo: *«Separate the Lambda handler from your core logic.
  This allows you to make a more unit-testable function.»* Es la fuente que justifica la
  arquitectura en capas del proyecto 01 sin recurrir a ningún blog de DDD.
  Úsala para: defender en una entrevista por qué organizas así una Lambda.
- [Using the SDK for JavaScript v3 in your handler (AWS)](https://docs.aws.amazon.com/lambda/latest/dg/typescript-handler.html#typescript-example-sdk-usage)
  Dice por qué empaquetar el SDK aunque venga en el runtime: la versión menor la elige AWS y
  la actualiza cuando quiere. Úsala para: los proyectos 01, 02 y 03.
- [Lambda quotas (AWS)](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html)
  Los números duros: 50 MB de zip por la API, 250 MB descomprimido incluyendo layers, 5 layers
  por función, 6 MB de payload síncrono. Úsala para: comprobar antes de afirmar.
- [Node.js test runner (Node.js docs)](https://nodejs.org/api/test.html)
  `node:test`, `mock`, `--watch` y el glob de ficheros. Cero dependencias.
  Úsala para: los tests de todos los proyectos con código propio.
- [TypeScript en Node.js — type stripping (Node.js docs)](https://nodejs.org/api/typescript.html)
  Qué sintaxis se puede borrar y cuál no. Explica el `ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX` de las
  *parameter properties*, los `enum` y los `namespace`.
- [Zod — documentación oficial](https://zod.dev/)
  Esquemas, `safeParse`, `.brand()`, y [Zod Mini](https://zod.dev/packages/mini) con su API de
  funciones sueltas para *tree shaking*. Úsala para: validar en la frontera de cualquier Lambda.
- [Lambda durable functions (AWS)](https://docs.aws.amazon.com/lambda/latest/dg/durable-functions.html)
  Checkpoint y replay, *steps* y *waits*, y la comparación honesta con Step Functions.
  Úsala para: el proyecto 03, donde encadenar llamadas a un modelo sí lo justifica.
- [Lambda Managed Instances (AWS)](https://docs.aws.amazon.com/lambda/latest/dg/lambda-managed-instances.html)
  Qué es un *capacity provider*, el +15% de gestión, y la tabla de diferencias con Lambda por
  defecto. Lo importante para una entrevista es la multi-concurrencia por entorno.

## Wisdom (Comunidades)

- [r/Terraform](https://reddit.com/r/Terraform)
  Alto ratio de señal. Gente resolviendo problemas reales de state, módulos y CI.
  Úsala para: enseñar tu estructura de proyecto y que te la critiquen antes de una entrevista.
- [HashiCorp Discuss — Terraform](https://discuss.hashicorp.com/c/terraform-core/27)
  Foro oficial. Responden ingenieros de HashiCorp.
  Úsalo para: dudas de comportamiento del core (state, providers, plan diffs raros).
- [r/aws](https://reddit.com/r/aws)
  Úsala para: preguntas de diseño y de coste. La gente es brutalmente honesta sobre facturas.
- [Stack Overflow — tag `terraform`](https://stackoverflow.com/questions/tagged/terraform)
  Úsalo para: errores concretos con mensaje literal. Busca el mensaje entre comillas.

## Gaps

- Falta un recurso de calidad sobre **testing de Terraform** (Terratest, `terraform test`).
  Buscarlo cuando lleguemos al proyecto 07. Ojo: los tests de la lección 06 son de *tu código*,
  no de la infraestructura — son dos disciplinas distintas y no hay que mezclarlas.
- Falta una fuente fiable sobre **patrones de red multi-región** en AWS más allá del marketing.
  Buscarlo antes del proyecto 05.
