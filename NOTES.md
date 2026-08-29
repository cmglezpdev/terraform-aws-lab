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

## Lección 06 — el código de la Lambda (2026-08-25, LR-0011)

Frenó el roadmap por su cuenta: *«solo tengo una función demasiado trivial»*. Primera vez que
rechaza avanzar por sentir que el ejemplo es de juguete — hay que atenderlo, no aplazarlo.

- **La frase de AWS que ordena todo** y es vocabulario compartido desde hoy:
  *«Separate the Lambda handler from your core logic. This allows you to make a more
  unit-testable function.»* Leída al revés es una prueba de diagnóstico: **si para probar una
  función necesitas AWS, la función sabe demasiado sobre AWS.** Y su corolario: **la
  testabilidad no es consecuencia de las capas, es su definición operativa.**
- **Excepción razonada a LR-0005:** la lección dura 45 min en vez de 40 y no se partió, porque
  separar arquitectura / dependencia / tests convertiría una regla en tres manías de estilo. La
  lección dice dónde parar si va justo (fin del paso 3). Si vuelve a pasar, mismo criterio: se
  parte por temas, no por minutos, y se dice siempre.
- **Honestidad sobre el DDD:** `application/` tiene seis líneas y hoy NO se justifica. Se dijo
  con esas palabras y se fijó fecha: la lección 07 o se borra. Precedente — cuando se introduce
  una estructura antes de que exista su motivo, hay que decir cuándo se justificará y qué pasa
  si no lo hace.
- **Bug real suyo descubierto de paso:** el sourcemap viaja dentro del `.zip` porque
  `archive_file` usa `source_dir`. Con zod son 985 857 B de `.map` frente a 327 893 B de bundle
  — el 75% del paquete. Arreglado con `source_file`, verificado con Terraform 1.15.8: el zip
  conserva `index.mjs` en la raíz (usa el *basename*) y baja a 65 437 B.
- **Tamaños medidos** (esbuild 0.28.2, `--minify`, ESM, node24): sin deps 563 B → con `zod`
  327 893 B (×582). `zod/mini` 8 944 B pero API de funciones sueltas, sin `.max()` encadenado.
  `@aws-sdk/client-dynamodb` bundleado: 504 422 B.
- **Tests con cero dependencias:** Node 24 ejecuta TS directamente.
  `node --test 'src/**/*.test.ts'` — comillas simples, el glob lo expande Node.
  Hace falta `allowImportingTsExtensions: true` (solo válido con `noEmit`).
- **Trampa nueva que hay que recordar al escribir TypeScript de ahora en adelante:** Node borra
  tipos, no compila. `constructor(readonly x: string)` revienta con
  `ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX: TypeScript parameter property is not supported in
  strip-only mode`. Igual con `enum` y `namespace`.
- **zod valida pero no normaliza.** `new URL().toString()` añadía la barra final;
  `z.httpUrl()` no, hace falta `normalize: true`. Patrón general para repetirle: **al sustituir
  código propio por una librería, lo que se rompe no es lo que la librería hace peor, sino lo
  que tu código hacía sin que tú lo supieras.**
- **La captura que trajo** eran *durable execution* y *EC2 capacity provider* (re:Invent 2025).
  Ninguna aplica: managed instances no escala a cero y rompe la regla de coste. Ficha en
  `reference/aws-lambda.html#capacidades-2026`. **Volver a durable execution en el proyecto 03.**
- **Apuesta falsable pendiente de resolver:** se le predijo que el ×134 del zip apenas movería
  el `Init Duration`. Le pedí las dos líneas `REPORT` (lección 05 y 06). **Si la apuesta falla,
  decírselo y pasar a `zod/mini`** — el valor está en cumplir el trato salga como salga.
- **CORRECCIÓN SUYA (2026-08-27), y tenía razón:** zod no puede vivir en `domain/`. La regla que
  yo di («prohibido el SDK de AWS, tipos de eventos, `process.env`») era demasiado corta. La
  buena es **nada que aparezca en el `package.json`**; globales del lenguaje (`URL`, `Date`,
  `Intl`, `node:crypto`) sí. El reparto correcto: **la regla** en `domain/` como dato exportado,
  **la forma del payload** en `application/` con zod, **el mecanismo** donde esté la librería.
  Prueba: cambiar zod por Valibot no debe tocar `domain/`.
- **Heurística nueva que salió de ahí y hay que reutilizar:** *cuando un caso de prueba no sabe a
  qué fichero pertenece, la frontera está mal puesta*. Al mover el esquema, los tests se
  repartieron solos y la firma del dominio pasó de `unknown` a `string`.
- **Corrección a mí mismo sobre layers:** fui más tajante de lo que la doc respalda. AWS da cinco
  motivos legítimos (incluido **fijar la versión del SDK embebido**) y solo desaconseja layers
  explícitamente para **Go y Rust**, por el coste de cargar assemblies en el *Init*. Para JS es
  un intercambio, no un error. No repetir la versión absolutista.
- **Datos para «¿y cuando tenga muchas librerías?»** (medido 2026-08-27): siete dependencias
  típicas de una API dan `node_modules` de 58 MB / 10 218 ficheros, bundle de 1 076 KB y zip de
  286 KB — el **0,6%** del límite de 50 MB. esbuild reduce 54×. **Cabe Express/NestJS entero en
  una Lambda**: la restricción no es el tamaño, es el modelo de ejecución. Vigilar el *Init*.
- **Granularidad de funciones**: tabla de intercambios en
  `reference/typescript-lambda.html#cuantas-lambdas`. Heurística: **agrupa por permisos, no por
  entidad** — el eje de IAM es el único que no se compensa después. Se desarrolla en la lección
  08 con API Gateway y el `for_each` sobre un mapa de funciones.
- **Marco que puso él y hay que respetar:** *«no es un curso de Lambda, es un curso de Terraform
  aplicado a AWS»*. Cuando pregunte por AWS puro: respuesta corta en el chat, material duro a la
  ficha de referencia, y **no inventar una lección nueva** salvo que él la pida.
- **Renumeración:** DynamoDB pasa a ser la lección 07 y API Gateway la 08. Anotado en el
  ROADMAP, en la lección 05 (con nota fechada al pie) y en el README del proyecto 01.

## Lección 07 — la memoria del acortador (2026-08-28, LR-0012)

- **La deuda de `application/` queda saldada**: puerto `LinkRepository` + `CodeCollisionError`
  en `application/` (idioma del contrato), adaptador en `infrastructure/` (único fichero que
  conoce el SDK), reintento ×3 en el caso de uso, handler como **raíz de composición** —
  término nuevo, junto a puerto/adaptador. `process.env` solo en el handler.
- **`handler.test.ts` se borró con argumento**: el handler ahora crea el `DynamoDBClient`; su
  prueba es el despliegue. Los 14 tests siguen siendo 14 (salen 2, entran 2 de colisiones).
- **Trampa central AWS**: `PutItem` es upsert — sin `attribute_not_exists(code)` machaca en
  silencio. Tercera entrega del hilo «fallo silencioso» (ARN sin `:*`, sourcemap, upsert).
- **Trampa central Terraform**: el bloque `attribute` es la lista de claves, no un esquema —
  un atributo de más da el *plan infinito* del provider y ni `validate` ni `plan` avisan.
  Y `billing_mode` por defecto es `PROVISIONED` (cobra por hora): segundo «el default del
  provider no es tu default», tras `x86_64`.
- **API nativa (`{S: …}`) y no `lib-dynamodb`**, con fecha de reevaluación: proyecto 02.
- **Verificación de la lección**: `aws dynamodb get-item` con el código del `ok.json`
  (`node -p 'require("./ok.json").code'` — sin depender de jq). El 200 no demuestra nada.
- **Medido**: bundle 835 728 B (SDK ≈ +508 KB), zip 216 388 B (×3,3 sobre lección 06).
- **La apuesta del Init Duration sigue sin cobrarse** — reclamada en cabecera y cierre de la
  lección 07. Si tampoco trae los REPORT, en la 08 se pide como primer paso o se retira.
- **Refactor pedido por él (2026-08-28)**: partir `main.tf` por componentes — `dynamodb.tf`,
  `create-link.tf` (identidad → logs → llave de datos → artefacto → función, en orden
  narrativo), `outputs.tf`, `main.tf` solo con locals. Criterio elegido: **por componente, no
  por tipo de recurso** — todo lo que ES create_link vive junto. Enseñanza asociada: Terraform
  fusiona todos los `.tf` del directorio; el reparto es para humanos y `terraform plan` da «No
  changes» como prueba. Preferencia suya a respetar en proyectos futuros.
- La pregunta incómoda del cierre («¿el fake prueba de verdad?») tiene respuesta preparada en
  LR-0012: el fake prueba la política de reintento; la atomicidad la garantiza la condición.
- Precios/límites de DynamoDB verificados 2026-08-28 (Price List API + doc); están en la ficha.
- **Bug encontrado por él al desplegar (2026-08-28)**: `Dynamic require of "node:https" is not
  supported` al invocar. El SDK trae CJS; esbuild en ESM deja un stub de `require` que solo
  falla cuando el bundle se carga como ESM puro — el runtime de Lambda. **Mi prueba de humo
  mentía**: importaba el bundle desde `node -e` (CJS) y el stub encontraba ese `require`.
  Arreglo verificado: `--banner:js="import { createRequire } from 'node:module'; const require
  = createRequire(import.meta.url);"` en el script de build (+93 bytes). Añadido a la lección
  07 como trampa. **Regla nueva para verificar bundles ESM: la prueba de humo debe ejecutarse
  desde un `.mjs`, nunca desde `node -e`.**
- Él también tuvo que añadir `dynamodb:*` a la política `terraform-course` de
  `00-foundations/iam.tf` para poder aplicar — correcto y en el sitio correcto; la lección 07
  no lo avisaba. Precedente: cada lección que estrene servicio debe avisar de tocar antes la
  política del usuario en el proyecto 00.

## Lección 08 — la puerta pública (2026-08-28, LR-0013)

- **Publicada sin sesión de por medio**: diseñada y verificada el mismo día que la 07 quedó
  registrada. Alcance decidido: **solo la puerta** (`POST /links` público). La segunda Lambda,
  el 301 y el `for_each` prometidos en la 07 pasan a la **lección 09** — el corte está
  declarado dentro de la lección con su porqué (LR-0005).
- **La apuesta del Init Duration: RESUELTA el 2026-08-29 — sostenida.** Él trajo las líneas:
  antes 145,09 y 91,08 ms (bundle pequeño), después 172,83 ms → 27,74 ms < 100. No hay
  `zod/mini`. **Asterisco anotado en la lección**: la varianza intra-artefacto (91→145;
  173→332) supera el umbral — el criterio comparaba muestras sueltas; «un Init no es una
  medición, es una muestra» queda como frase reutilizable. **Dos hallazgos de sus líneas**:
  (1) `Billed = Duration + Init` en las cuatro — el init de runtimes gestionados se cobra
  desde agosto de 2025 (blog «standardizes billing for init phase»; casi todo internet dice
  lo viejo, mismo patrón que `use_lockfile`); (2) las `INIT_REPORT Status: error` de su log
  son la autopsia del bug del `Dynamic require`, con el *suppressed init* (`Phase: invoke`)
  incluido — INIT_REPORT solo se emite cuando el init falla. Pendiente de confirmar: si el
  REPORT de 332,03 ms / 913,59 ms es el primer `curl` por la puerta (credenciales + TLS con
  DynamoDB en la primera invocación real).
- **Terceras entregas de dos hilos**: `payload_format_version = "1.0"` por defecto en el
  provider (vs 2.0 de la consola) → «el default del provider no es tu default» nº 3;
  `aws_lambda_permission` ausente → 500 con logs vacíos → «fallo silencioso» nº 4, con la
  heurística *log vacío = el problema está antes de la función*.
- **El mapa IAM queda cerrado y hay que reutilizarlo así**: identidad (políticas del rol),
  confianza (`assume_role_policy`), **recurso** (`aws_lambda_permission`, leída con
  `aws lambda get-policy`). La «política de recurso» de SNS (lección 02) es la misma clase —
  religada en el glosario.
- **El handler = raíz de composición + adaptador de protocolo.** Errores esperados se
  traducen (400), imprevistos se relanzan (500 de verdad). Solo `handler.ts` cambió; 14/14
  tests intactos. Bundle 836 125 B (+397 B). Humo verificado desde `.mjs` (regla LR-0012).
- **`integration_method = "POST"` ≠ el método del cliente** — el `GET /{code}` de la 09
  también se integra con POST. La quiz 1 de la lección lo prepara.
- La lección abre recordando ampliar la política del proyecto 00 con `apigateway:*`
  (precedente LR-0012, cumplido por primera vez). Las acciones IAM de API Gateway son verbos
  HTTP (`apigateway:POST`), no nombres de operación.
- **Pendiente al cerrar la 09**: borrar `ok.json`/`malo.json` viejos si ya no pintan nada, y
  decidir si `smoke.mjs` se queda como script de repo o sigue siendo efímero.
- CORS queda sin configurar a propósito (el `curl` no lo dispara); `cors_configuration` está
  en la ficha para cuando haya frontend. La API queda **abierta a sabiendas** — la pieza que
  falta se llama authorizer y llega en el proyecto 03.

## Lección 09 — la segunda función (2026-08-29, LR-0014)

- **Avería real como paso 0**: su `handler.ts` retranscrito perdió dos `return` (ramas
  `ZodError`/`CodeCollisionError` → 500). Confirmada contra su bundle construido antes de
  publicar. La lección da el síntoma y pistas; el diagnóstico es suyo. Heurística nueva,
  inversa a la de la 08: **500 con logs = el fallo está dentro**. Al revisar su salida,
  comprobar que entendió por qué su humo no lo veía (no cubría el JSON con forma mala).
- **Vocabulario nuevo**: el puerto pertenece al consumidor (`LinkFinder` segregado, no
  ensanchar `LinkRepository`); la ausencia no grita (`GetItem` sin `Item` = 200 vacío,
  quinto fallo silencioso); «esto lo demuestra el test, no el curl» (el no-efecto solo lo ve
  el fake, `lookups.length === 0`).
- **301 elegido como decisión defendible**: cacheado para siempre; imposible corregir
  destinos o contar clics repetidos (los comerciales usan 302/307 por analítica). Si algún
  día pide contador de clics: el 301 es el obstáculo, no los permisos.
- **`smoke.mjs` es ya script permanente del repo** (`pnpm run smoke`, 6 contratos, dos
  bundles); `malo.json` jubilado — pendiente de LR-0013 resuelto. 22 tests.
- **Medido**: `create-link.mjs` 836 297 B, `get-link.mjs` 505 748 B — la diferencia es zod
  casi al byte. Reutilizar como prueba de «cada artefacto pesa lo que su handler sabe».
- **Trampa frontera código↔infra**: renombrar el bundle exige `handler =
  "create-link.handler"`; si se olvida, `apply` triunfa y la invocación da
  `Runtime.ImportModuleError`. Mismo género que `payload_format_version`.
- **El `for_each` se aplazó por segunda vez, declarado** con motivo nuevo: hacía falta que
  los gemelos existieran (hoy se siente el copia-pega) y el paso a `for_each` cambia
  direcciones en el state → plan destruir-y-recrear → **lección 10: bloques `moved`, «el
  refactor invisible»**, quiz 1 lo deja preparado. `get-link.tf` declara en su comentario
  que la duplicación es deliberada. No aplazarlo una tercera vez.
- Rutas verificadas contra la doc: variable = un segmento; específica > variable >
  `{proxy+}` > `$default`. Los tres 404 tienen dos autores (dos suyos, uno de la puerta).
- La pregunta del cierre (por qué el bundle lector pesa 330 KB menos) tiene la respuesta
  buena en LR-0014 — exige nombrar el reparto por consumidor, no solo «no usa zod».

### Su implementación (2026-08-29, comiteada el mismo día) — divergencias a seguir

Hizo la lección por su cuenta antes de que se revisara, con variaciones propias, casi todas
buenas: `Link` unificado en `domain/link.ts` (deduplicación que la lección dejó pasar a
propósito), adaptador `DynamoDbLinkFinder` en clase separada (válido; la lección usaba una
clase con dos puertos), y el fix del paso 0 lo encontró y comiteó solo. Tres cosas abiertas:

1. **Eligió 302, no 301** en `get-link.ts`. Divergencia legítima (corregible + contable) —
   pero hay que pedirle que la defienda con los dos precios del 301 delante. Si la defiende
   bien, es señal de madurez; actualizar el README del proyecto con su porqué.
2. **`CodeCollisionError` → 400** en su `create-link.ts`. La lección argumenta 500 (agotar
   reintentos no es culpa del cliente). Preguntarle de quién es la culpa en ese caso; no
   corregido a propósito.
3. **Imports muertos en `handlers/get-link.ts`** (z, createLink, DynamoDbLinkRepository…
   restos del copia-pega): su `get-link.mjs` pesa 815 KB — igual que el gemelo — y la
   pregunta del cierre de la lección no funciona con su build. `tsc` no avisa porque
   `noUnusedLocals` está comentado en su tsconfig. Señalado como ejercicio al comitear;
   verificar en la próxima sesión que el bundle bajó a ~500 KB (y valorar activar
   `noUnusedLocals`).

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
- ~~**Tests del código de las Lambdas.**~~ — **hecho** en la lección 06 con `node --test`. Lo
  que sigue pendiente es **ejecutarlos automáticamente** (CI) y los tests de integración contra
  AWS real, ambos en el proyecto 07.
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
