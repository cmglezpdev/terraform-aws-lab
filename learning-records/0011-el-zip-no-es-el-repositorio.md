# Preguntó por DDD, librerías y tests — y las tres eran la misma pregunta

2026-08-25, justo antes de entrar en DynamoDB. Frenó el roadmap por su cuenta con una frase que
vale la pena citar: *«quiero llevar un poco más la lambda al límite, porque por ahora solo tengo
una función demasiado trivial»*.

## Por qué esto es una buena señal

Es la primera vez que **rechaza avanzar por sentir que el ejemplo es de juguete**, que es
exactamente la queja que [LR-0001](./0001-punto-de-partida.md) recoge sobre los tutoriales. Antes
lo decía de los materiales ajenos; ahora lo dice del curso. Hay que atenderlo, no despacharlo con
«ya llegará».

Las tres preguntas venían seguidas y no era casualidad:

| Lo que preguntó | Lo que preguntaba en realidad |
|---|---|
| ¿Cómo hago arquitectura tipo DDD, módulos? | ¿Puede mi código no saber que vive en Lambda? |
| ¿Y si instalo `zod`? | ¿Qué le pasa al artefacto cuando el repositorio crece? |
| ¿Los tests cómo entran? | ¿Qué puedo verificar sin AWS? |

**Se decidió no partir la lección**, aunque salen 45 min y la restricción del curso son 40. El
motivo está escrito en la propia lección: separadas, las tres parecen manías de estilo; juntas
son una regla. La concesión es que la lección dice explícitamente dónde parar si va justo de
tiempo (fin del paso 3) y que los tests están aislados a propósito. Es una excepción razonada a
[LR-0005](./0005-una-leccion-un-tema.md), no un olvido.

## La frase que resuelve las tres, y es de AWS

> *«Separate the Lambda handler from your core logic. This allows you to make a more
> unit-testable function.»*
> — [Code best practices for TypeScript Lambda functions](https://docs.aws.amazon.com/lambda/latest/dg/typescript-handler.html#typescript-best-practices)

Es la **primera** viñeta de esa lista, y mete arquitectura y tests en la misma frase. Leída al
revés es una prueba de diagnóstico que hay que reutilizar: **si para probar una función necesitas
AWS, la función sabe demasiado sobre AWS.** Vocabulario compartido a partir de ahora, igual que
los cuatro niveles del arranque ([LR-0008](./0008-niveles-del-arranque.md)) y la pregunta de tres
partes ([LR-0010](./0010-el-grafo-y-como-se-aprende.md)).

Corolario que ordena las capas sin ceremonia: **la testabilidad no es una consecuencia de las
capas, es su definición operativa.** Una capa que no se prueba más fácil que la de abajo no se ha
ganado el directorio.

## Honestidad sobre el DDD: la capa de aplicación aún no se ha ganado el sitio

`application/create-link.ts` tiene seis líneas y hoy no justifica su existencia. **Se dijo en la
lección con esas palabras**, en vez de vender que sí. Se justifica en la lección 07, cuando reciba
el repositorio de DynamoDB y tenga que reintentar ante colisiones — y si ese día no aparece la
razón, se borra. Está apuntado como deuda explícita en «esto no lo demuestra».

Precedente: cuando una estructura se introduce *antes* de que su motivo exista, hay que decir la
fecha en que se justificará y qué pasa si no lo hace. Si no, es cargo cult con buena prensa.

## Me corrigió, y tenía razón: zod no puede vivir en el dominio

2026-08-27, revisando la lección antes de hacerla. Sus palabras: *«no puede ir en dominio porque
estás usando una librería externa que es zod, el dominio no la puede conocer, el dominio es
TypeScript puro»*.

**Es correcto, y contradecía la regla que la propia lección acababa de dar.** Yo había escrito
que `domain/` tiene prohibido importar «el SDK de AWS, tipos de eventos, `process.env`» — una
lista demasiado corta. La regla buena es más simple: **nada que aparezca en tu `package.json`.**

Lo que sí hay que precisar, porque es la parte que no es obvia y es la que enseña:

| | Dónde vive | Ejemplo |
|---|---|---|
| La **regla** | `domain/`, exportada como dato puro | `ALLOWED_PROTOCOLS`, `MAX_URL_LENGTH` |
| La **forma** del payload | `application/`, con zod | `z.object({ url: z.string() })` |
| El **mecanismo** | Donde esté la librería | `safeParse`, `ZodError` |

Prueba de que la separación es la correcta: **cambiar zod por Valibot no debe tocar `domain/`.**

Y el efecto secundario que confirma que la frontera quedó bien puesta: al mover el esquema, los
tests **se repartieron solos**. `42`, `null` y `{}` caen en `create-link.test.ts`;
`"javascript:alert(1)"` y `"ftp://…"` en `target-url.test.ts`. Además la firma del dominio pasó
de `parseTargetUrl(raw: unknown)` a `parseTargetUrl(raw: string)`: ya no se defiende de tipos
porque la capa de arriba lo hizo. **Heurística nueva y reutilizable: cuando un caso de prueba no
sabe a qué fichero pertenece, la frontera está mal puesta.**

Nota sobre cómo se detectó: no lo pilló él leyendo teoría, lo pilló **aplicando la regla que yo
mismo le había dado dos párrafos antes**. Eso es exactamente lo que [LR-0010](./0010-el-grafo-y-como-se-aprende.md)
quería provocar. Cuando vuelva a corregir el material, darle la razón sin adornos y arreglar la
lección antes de que la haga.

## Sus otras tres preguntas (2026-08-27), y dónde quedaron contestadas

Vinieron con un marco explícito suyo que hay que respetar: *«no es un curso de Lambda, es un
curso de Terraform aplicado a AWS»*. Respuestas cortas al chat, material duro a la ficha, y
nada de inventar una lección nueva.

- **«¿Y cuando tenga muchas librerías?»** — Medido: siete dependencias típicas de una API
  (`zod`, cuatro clientes del SDK, Powertools, `date-fns`) dan `node_modules` de **58 MB y 10 218
  ficheros**, y un bundle de **1 076 KB** / zip de **286 KB**: el **0,6%** del límite de 50 MB.
  esbuild reduce 54 veces. La respuesta es «no pasa nada», con número.
- **Su premisa falsa, que había que desmontar:** *«si las lambdas solo puedo usar código de
  TypeScript sencillito, no le veo mucho sentido»*. Falso: cabe Express, Fastify, Hono o NestJS
  entero. La restricción de Lambda **no es el tamaño del código**, es el modelo de ejecución.
  Cuidar el *Init*, no los megabytes.
- **«¿Una Lambda por endpoint?»** — Tabla de intercambios en
  `reference/typescript-lambda.html#cuantas-lambdas`. La heurística que se le dio:
  **agrupa por permisos, no por entidad.** El eje de IAM es el único que no se puede compensar
  después, porque los permisos se conceden por función — la granularidad de las funciones **es**
  la granularidad del privilegio mínimo. Y para su caso concreto: `create_link` y `redirect` son
  dos funciones porque una necesita `PutItem` y la otra `GetItem`.
- **Sobre layers, corrección a mi propia lección:** fui más tajante de lo que la doc respalda. La
  doc de AWS da cinco motivos legítimos, incluido **fijar la versión del SDK embebido**, y su
  única recomendación explícita en contra es para **Go y Rust**, por el coste de cargar
  assemblies en el *Init*. Para JS es un intercambio, no un error.

**Pendiente en el ROADMAP:** la granularidad de funciones se desarrolla en la lección 08 con API
Gateway, y es donde entra el `for_each` sobre un mapa de funciones que el proyecto 01 ya anuncia.

## Hallazgos verificados ejecutándolos (no leídos)

Todo lo de abajo se comprobó en una copia real de `projects/01-serverless-api/app`, con su misma
cadena de herramientas: pnpm 11.23.0, TypeScript 7.0.2, esbuild 0.28.2, Node 24.18.0,
Terraform 1.15.8. Verificado el 2026-08-25.

1. **El sourcemap viaja a AWS y es el 75% del paquete.** `source_dir` comprime `dist/` entero y
   esbuild deja dos ficheros. Con `zod`, `index.mjs.map` pesa 985 857 B frente a 327 893 B del
   bundle. Node no lo lee sin `--enable-source-maps`. Solución verificada: `source_file` en el
   `archive_file` — el zip conserva `index.mjs` en la raíz (usa el *basename*), así que
   `handler = "index.handler"` sigue valiendo, y el zip baja de 220 226 a 65 437 B.
   **Este bug lo tiene ahora mismo en el proyecto**; zod solo lo hizo visible.
2. **Tamaños medidos** (minificado, ESM, `--target=node24`): sin dependencias 563 B → con `zod`
   327 893 B (×582). `zod/mini` da 8 944 B pero con API de funciones sueltas, y `.max()`
   encadenado no existe ahí. `@aws-sdk/client-dynamodb` solo, bundleado: 504 422 B.
3. **Node 24 ejecuta TypeScript directamente**, así que `node --test 'src/**/*.test.ts'` da tests
   con **cero dependencias**. Ocho tests en <80 ms.
4. **La trampa que Node impone al estilo TypeScript**: `constructor(readonly x: string)` falla con
   `SyntaxError [ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX]: TypeScript parameter property is not
   supported in strip-only mode`. Node borra tipos, no genera código. Igual con `enum` y
   `namespace`. Es la primera vez en el curso que la herramienta de *ejecución* dicta la sintaxis.
5. **`allowImportingTsExtensions: true`** hace que `import "./errors.ts"` lo entiendan a la vez
   `tsc`, esbuild y Node. Solo se permite con `noEmit`, que es su caso.
6. **zod valida pero no normaliza**: `new URL(x).href` añade la barra final y `z.httpUrl()` a
   secas no. Tras la corrección de arriba el dominio se queda con `URL` nativo, así que la
   normalización no se pierde — pero el patrón hay que repetírselo igual: **al sustituir código
   propio por una librería, lo que se rompe no es lo que la librería hace peor, sino lo que tu
   código hacía sin que tú lo supieras.**
7. **Bundle con siete librerías reales**: 1 076 KB, zip 286 KB, frente a 58 MB y 10 218 ficheros
   de `node_modules` sin bundlear. Verificado el 2026-08-27.

## La captura de la consola: dos capacidades de re:Invent 2025

Preguntó por *Durable execution* y *EC2 capacity provider*. Ninguna aplica al curso, y el *por qué
no* es lo valioso:

- **Durable execution**: hasta un año por ejecución, con *checkpoint/replay* — el código se
  reejecuta desde el principio saltándose los pasos ya hechos. Las *waits* suspenden sin facturar
  cómputo. **Se mira otra vez en el proyecto 03** (gateway de IA): encadenar llamadas a un modelo
  con reintentos es su caso de uso estrella.
- **EC2 capacity provider (Lambda Managed Instances)**: EC2 en su cuenta, +15% de gestión, y
  **no escala a cero** → rompe la regla de coste del curso. El detalle que se pasa por alto y que
  sí es de entrevista: **multi-concurrencia**, un entorno atiende varias invocaciones a la vez, o
  sea que el estado de módulo pasa a ser estado compartido.

Ambas llevan el icono de «no se puede cambiar tras crear la función», que en Terraform significa
`ForceNew`. Está todo en [`reference/aws-lambda.html#capacidades-2026`](../reference/aws-lambda.html#capacidades-2026).

## Qué se escribió

- `lessons/0006-el-zip-no-es-tu-repositorio.html` — la lección.
- `reference/typescript-lambda.html` — ficha nueva: las tres capas, *parse don't validate*, tabla
  de tamaños del artefacto, dónde meter una dependencia, tests sin instalar nada, y la tabla de
  «qué prueba cada nivel y a qué es ciego».
- `reference/aws-lambda.html` — sección `#capacidades-2026`.

## Señal a vigilar

La lección le pide **comparar el `Init Duration` de la lección 05 con el de hoy**, y se le dijo
una apuesta explícita: que el ×134 del zip apenas se nota porque el arranque en frío lo domina
Node y la microVM. **Si la apuesta falla, hay que decírselo y pasar a `zod/mini`** — es la primera
vez que el curso hace una predicción falsable, y el valor pedagógico está en cumplir el trato
sea cual sea el resultado.
