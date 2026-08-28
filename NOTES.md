# Notas de trabajo

## Preferencias del usuario

- **Idioma**: español. Términos técnicos e identificadores de código en inglés.
- **Odia los ejercicios de juguete.** "Crea un bucket S3" no le sirve: no ve el caso de uso.
  Todo debe estar dentro de un proyecto con una razón de existir.
- **TypeScript siempre.** Nada de JS plano, Java, Go ni Python. Bundle con `esbuild`.
- Cree que Terraform es "bastante sencillo" y que la dificultad está en configurar AWS.
  Parcialmente cierto — pero state, módulos y el ciclo `plan` van a sorprenderle.
  No darle la razón por comodidad: enseñar los sitios donde Terraform sí es difícil.
- Quiere entender **por qué** cada pieza está donde está (System Design), no solo el cómo.

> Este fichero es público. Los identificadores de cuenta que aparezcan aquí y en el resto
> del repositorio son **marcadores de posición**, no valores reales.

## Entorno (verificado 2026-08-23)

- Terraform `v1.15.8` (Homebrew), AWS CLI `2.36.5`, Node `v24.18.0`, npm `11.16.0`.
- `~/.aws/config` tiene varios perfiles. El del curso es **`personal`**; hay otro de trabajo
  que no se toca. De ahí que toda lección empiece con `aws sts get-caller-identity`: nunca
  damos por hecho en qué cuenta estamos.
- No hay sesión activa por defecto. Usa `aws login` (config con `login_session`, no
  `sso_start_url`). Credenciales temporales, refresco automático, 12 h de tope, caché en
  `~/.aws/login/cache`, se tiran con `aws logout`.
- **Resuelto en la lección 04 (2026-08-24)**: `personal` = usuario IAM `terraform` (identidad
  de trabajo), `personal-root` = root (vía de escape). El usuario **no tiene claves de
  acceso**: entra por `aws login`. Ver [LR-0007](./learning-records/0007-usuario-iam-sin-claves.md).
- **`aws login` con un usuario IAM exige la política gestionada
  `arn:aws:iam::aws:policy/SignInLocalDevelopmentAccess`.** Root no la necesita. Está
  documentada solo en la guía de la CLI, no en la de IAM.

## Decisiones de enseñanza

- **Cada servicio AWS lleva su propio bloque explicativo** (petición explícita, LR-0004).
  Formato: `.anatomy` embebido en la lección (preguntas 1, 3 y 5) + referencia completa en
  `reference/aws-<servicio>.html`. Generado con el skill `aws-service-explainer`.
- **Nunca escribir precios ni límites de memoria.** Verificar contra la doc de AWS o, mejor,
  contra la Price List API pública:
  `https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/<Servicio>/current/<región>/index.json`
  (sin credenciales, devuelve JSON con las tarifas reales). Fecha de verificación en el doc.
- **Toda infra desplegada lleva un paso de verificación explícito** y una frase de «esto lo
  demuestra, esto no» (LR-0003). El usuario detectó por su cuenta que la alarma no estaba
  probada; ese reflejo hay que alimentarlo.
- La web del Terraform Registry es una SPA: `WebFetch` devuelve vacío. Usar siempre
  `https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/<recurso>.html.markdown`.

- Enseñar el backend S3 con `use_lockfile = true`, NO con DynamoDB (deprecado). Casi todo
  el material que encuentre por internet usará DynamoDB — avisarle explícitamente.
- Regla de coste: los proyectos 04 y 06 se aplican con cronómetro. El resto es pago por uso.
- Cada lección termina con un `destroy` verificado. Nunca dejar infra levantada "para mañana"
  sin decirlo explícitamente.

- **El truco de `terraform validate` con un valor inventado** es su autocompletado real para
  los argumentos de lista cerrada: el provider enumera los valores válidos en el error, sin
  credenciales y sin tocar AWS. Verificado el 2026-08-24 con su provider 6.61.0. Está en
  `reference/terraform-cli.html`. Usarlo siempre que pregunte «¿y qué valores acepta esto?»
  en vez de darle la respuesta directamente (LR-0009).
- **El informe de credenciales** (`aws iam generate-credential-report` +
  `get-credential-report`) es la forma no negociable de verificar el estado de root: MFA
  activo y claves de acceso inactivas. Estrenado en la lección 04. Reutilizarlo cada vez que
  se hable de seguridad de la cuenta, en vez de pedirle que mire la consola.
- **Los cuatro niveles del arranque privilegiado** (tabla al final de la lección 04) son ya
  vocabulario compartido: 0 módulo raíz que crea a su sucesor, 1 bootstrap aparte, 2 rol
  asumible, 3 organización con OIDC. Referirse a ellos por número. El proyecto 07 se presenta
  como «subir del 0 al 3», no como material nuevo (LR-0008).
- **Una lección, un tema** (LR-0005). Si al diseñarla no cabe en 40 min, se parte, y la
  lección dice al pie que se ha partido y por qué. No dejar que el usuario piense que se me
  olvidó lo que anuncié.
- **Resuelto (2026-08-24)**: todos los identificadores de cuenta del repositorio son
  marcadores de posición. El bucket de state se llama `tf-state-learning-course-terraform`,
  sin el ID dentro, así que `backend.tf` no expone nada. Si en el futuro un ejemplo necesita
  un ID, usar `999999999999`. La alternativa de *partial configuration* con
  `-backend-config=backend.hcl` sigue reservada para el proyecto 07.

## Proyecto 01 — decisiones tomadas (2026-08-24)

- **Se parte en tres lecciones**, y la lección 05 lo dice en su primera tabla: 05 el cerebro
  (Lambda), 06 la memoria (DynamoDB), 07 la puerta (API Gateway). Cabía forzarlo en dos, pero
  no en 40 min por sesión (LR-0005).
- **`sts:AssumeRole` se enseña dentro de la lección 05**, no como lección aparte: la política
  de confianza de una Lambda *es* el mecanismo, con `lambda.amazonaws.com` en `principals`.
  La idea de «los roles a fondo» que estaba anotada abajo queda cubierta en su parte esencial;
  lo que sigue pendiente es asumir un rol *entre cuentas* y con OIDC (proyecto 07).
- **`arm64` siempre.** Verificado el 2026-08-24: `0,0000133334` frente a `0,0000166667` USD
  por GB-segundo — exactamente un 20% menos. El provider usa `x86_64` por defecto.
- **El build nunca entra en Terraform.** `npm run build` → `plan` → `apply`. El `archive_file`
  se resuelve en el `plan`, así que el orden no es una preferencia. Los `provisioner` y el
  `null_resource` para construir se discuten en el proyecto 03, como antipatrón.
- **`aws_cloudwatch_log_group.arn` viene SIN el sufijo `:*`** (el provider lo quita a
  propósito), y `logs:PutLogEvents` lo necesita. Misma forma que el error del bucket contra el
  objeto de la lección 04, pero el síntoma es silencio en vez de `AccessDenied`. Es la trampa
  central de la lección 05.
- **No se adjunta `AWSLambdaBasicExecutionRole`.** Concede `CreateLogGroup` sobre `"*"`, y
  como el grupo lo crea Terraform la función no necesita crear nada. Dos acciones, un ARN.
- **Este es el primer proyecto que se queda desplegado entre sesiones**, y la lección lo dice
  con todas las letras junto al motivo (cuesta cero en reposo) y el comando de `destroy`.
### Cadena de herramientas de Node (revisada con él el 2026-08-24)

Él detectó que las dependencias que puse estaban desfasadas y pidió pnpm. Tenía razón en todo,
y todo lo de abajo está **comprobado ejecutándolo**, no leído:

- **pnpm 11**, fijado con `packageManager` en el `package.json`. El argumento de venta para él
  no es la velocidad, es la seguridad: pnpm **bloquea por defecto los `postinstall`** de las
  dependencias (`ERR_PNPM_IGNORED_BUILDS`). esbuild necesita el suyo.
- **La clave de aprobación es `allowBuilds` en `pnpm-workspace.yaml`**, no
  `onlyBuiltDependencies` en el `package.json`. Lo comprobé equivocándome: pnpm 11 reescribe el
  fichero solo y deja `allowBuilds: {esbuild: "set this to true or false"}`. Casi todo internet
  dirá lo viejo — mismo patrón que `use_lockfile` frente a DynamoDB.
- **pnpm SÍ ejecuta `prebuild`/`postbuild`** automáticamente en la v11. Iba a advertirle de lo
  contrario; era información de pnpm 7. Verificado con un `echo` dentro del script.
- **TypeScript 7.0.2** (compilador nativo en Go) y **esbuild 0.28.2**. Yo había puesto `^5.6.0`
  y `^0.25.0`.
- **`tsc --init` genera el tsconfig**, y el de TS7 ya trae `strict`, `verbatimModuleSyntax`,
  `isolatedModules` y `noUncheckedIndexedAccess`. Solo hay que tocar cuatro cosas:
  `types: ["node"]`, `noEmit: true` (en vez de `declaration`), `include: ["src"]` y borrar
  `jsx`. Preferir esto a `@tsconfig/node24`, que existe pero es más viejo que el generador.
- **Se pasa a ESM**, no por moda: TS7 genera `module: "nodenext"` + `verbatimModuleSyntax`, y
  eso prohíbe `import` en un paquete CommonJS. Salida `dist/index.mjs`. **La extensión no es
  opcional**: el zip solo lleva `dist/`, sin `package.json`, así que un `.js` con `import` se
  ejecutaría como CJS y reventaría. El bundle ESM además baja de 1.052 a 584 bytes.
- **`@types/node` clavado a la versión del runtime (24), no a la última.** pnpm avisa de que
  hay 26 disponible; se ignora a propósito. Es un buen ejemplo de «los tipos describen dónde se
  ejecuta, no dónde se escribe».

**Corrección de un dato suyo:** dijo tener Node 26. `node --version` da `v24.18.0` y
`fnm list` solo tiene esa. Usa **fnm**. No cambia nada —el `--target=node24` de esbuild es lo
correcto igualmente— pero si algún día instala la 26 en local, el target sigue siendo 24.

- Código verificado antes de publicar la lección: `npm run typecheck`, `npm run build` y el
  handler ejecutado en local con los tres casos malos; `terraform validate` + `fmt` con
  Terraform 1.15.8, la misma versión que él tiene. `type = string` en los `output` valida.
  Revisado otra vez el 2026-08-24 con pnpm 11.17.0, TypeScript 7.0.2 y esbuild 0.28.2, en ESM.

## Método de enseñanza añadido el 2026-08-24 (LR-0010)

- **Las dos políticas de un rol se explican SIEMPRE separadas y con la analogía del uniforme.**
  `assume_role_policy` = quién puede ponérselo (mira afuera); `aws_iam_role_policy` = qué
  puertas abre (mira adentro). Se atascó justo ahí. La palabra «policy» compartida es la trampa.
- **La pregunta de tres partes** es vocabulario compartido desde hoy, como los cuatro niveles
  del arranque (LR-0008): (1) ¿con qué identidad actúa? (2) ¿quién puede usar esa identidad?
  (3) ¿sobre qué actúa y quién crea esos recursos? Presentar ECS, EventBridge y el OIDC del
  proyecto 07 como «las mismas tres preguntas, otro principal» — no como material nuevo.
- **Distinguir obligatorio de opcional en cada grafo.** Daba por hecho que los cuatro recursos
  de la Lambda hacían falta. Solo el rol lo es. Hacerlo explícito en cada servicio nuevo.
- **La autopsia consola → código** (`import` + `terraform plan -generate-config-out`) es la
  respuesta a «¿cómo se aprende esto?». Está en `reference/terraform-cli.html#autopsia`.
  Ofrecérsela cada vez que un servicio nuevo le parezca demasiadas piezas. Aviso honesto: el
  flag sigue etiquetado *experimental* en 1.15.8.
- **Dato de oro que hay que reutilizar:** la consola de Lambda **modifica tu rol IAM sin
  decírtelo** y concede logs sobre `*` (está en la doc de AWS, con casilla «Add required
  permissions» para impedirlo). Es la prueba citable de que la IaC no añade complejidad, sino
  que revela la que la consola escondía mal.
- Cuando se queje de que «hay que ser consciente de cada cosa»: nombrarle que esa incomodidad
  *es* el aprendizaje y es lo que le separa en una entrevista — pero **siempre acompañado de
  una herramienta concreta**, nunca como consuelo suelto.

## Ideas para futuras lecciones

- El `plan` como herramienta de lectura: enseñarle a leer un diff de 200 líneas.
- Quitar el presupuesto canario de 1 USD cuando la cuenta cumpla ~5 semanas y `FORECASTED`
  despierte. Anotado hacia finales de septiembre de 2026.
- `terraform state mv` / `import` — lo que separa a quien sabe de quien copia.
- ~~`sts:AssumeRole` y los roles a fondo~~ — **cubierto en lo esencial** en la lección 05,
  con `lambda.amazonaws.com` como principal de la política de confianza. Sigue pendiente la
  parte de entrevista de verdad: asumir un rol **entre cuentas**, `external_id` y el confused
  deputy en roles, y OIDC sin claves (proyecto 07).
- **Tres cosas de Lambda quedan ofrecidas al pie de `reference/aws-lambda.html`** y no se han
  enseñado: elegir la memoria midiendo (Power Tuning), `layers`, y `versions`/`aliases` para
  despliegues canarios. Ninguna hace falta para el proyecto 01.
- **Tests del código de las Lambdas.** La lección 05 admite en «esto no lo demuestra» que
  probar a mano no es probar. Encaja en el proyecto 07, junto a CI.
- **MFA para el usuario `terraform`**: no se puede crear desde Terraform (hace falta escanear
  un QR). Queda pendiente y la lección 04 lo dice en «esto no lo demuestra».
- **Activar el acceso de IAM a la consola de facturación** (tarea de root). Sin ello el
  usuario `terraform` no puede ver el presupuesto que él mismo gestiona. Ofrecido en la
  lección 04, no forzado.
- Por qué `count` rompe cosas al borrar el elemento del medio, y `for_each` no.
- Un post-mortem provocado: corromper el state a propósito y recuperarlo. **Prometido
  explícitamente en la lección 03** («la vamos a hacer provocando el desastre a propósito»).
  Con el versionado de S3 ya activo, se hace recuperando un `VersionId` anterior.
- Reglas de ciclo de vida de S3 — la ficha `reference/aws-s3.html` las deja fuera a propósito
  y ofrece explicarlas si las pide. Encajan de forma natural en el proyecto 02.
- ~~`terraform init -reconfigure` frente a `-migrate-state`~~ — **hecho** en la lección 04,
  como tercer bloque de recuperación (LR-0006).
