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
