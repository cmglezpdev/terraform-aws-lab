# DynamoDB entra por la clave, y `application/` se gana el sitio

2026-08-28, lección 07. La deuda contraída en [LR-0011](./0011-el-zip-no-es-el-repositorio.md)
—«la capa de aplicación se justifica en la lección 07 o se borra»— vence hoy, y la lección se
diseñó alrededor de ese vencimiento: el repositorio como puerto, la colisión de códigos como
motivo, y el `git diff` como juez (si `domain/` aparece en el diff, la promesa de las capas era
humo).

## Las decisiones de diseño de la lección

- **La clave de partición es `code`, y la lección lo presenta como decisión, no como
  obviedad.** Los dos tropiezos del reflejo SQL: no existe autoincremento (un contador central
  es lo que no escala), y la clave es *la pregunta que la tabla puede responder*, no un número
  de fila. Bonus que conviene reutilizar: los códigos de `randomBytes` de la lección 05 son
  el caso ideal de distribución uniforme — una decisión de dominio que resultó ser también la
  decisión correcta de base de datos.
- **La trampa central es que `PutItem` no inserta: reemplaza.** Sin `ConditionExpression`,
  escribir un código existente devuelve 200 y machaca el enlace de otro — mismo género que el
  ARN sin `:*` de la lección 05: no revienta, *corrompe*. `attribute_not_exists(code)` es la
  corrección del sistema, no una optimización. Tercera entrega del patrón «fallo silencioso»;
  ya es un hilo conductor del curso.
- **La trampa Terraform es el bloque `attribute`**: no es un esquema, es la lista de claves.
  Declarar un atributo normal produce el *plan infinito* documentado por el provider — y ni
  `validate` ni `plan` avisan. Segunda entrega de «el default del provider no es tu default»:
  `billing_mode = "PROVISIONED"` por omisión, como `x86_64` en Lambda.
- **El reparto de capas quedó así**: puerto (`LinkRepository`) y su error
  (`CodeCollisionError`) en `application/` — el error es idioma del contrato, no del dominio
  (el dominio no sabe que se guarda) ni del adaptador (cualquier implementación debe lanzar el
  mismo). Adaptador en `infrastructure/`, único fichero que conoce el SDK. Reintento (3
  intentos, regenera solo el código, la URL validada no se toca) en el caso de uso. El handler
  queda como **raíz de composición** — término nuevo — y `process.env` solo aparece ahí.
- **Se borró `handler.test.ts`, y la lección lo dice con todas las letras.** El handler ahora
  crea un `DynamoDBClient`; probarlo sin AWS o revienta o miente. Es la frase de AWS aplicada
  al fichero cuyo trabajo *es* saber de AWS: su prueba es el despliegue, y los tests de
  integración llegan con CI (proyecto 07). Borrar un test con argumento es mejor lección que
  mantenerlo de teatro.
- **Los 14 tests siguen siendo 14**: salen 2 del handler, entran 2 de colisiones. Casualidad
  aritmética, pero útil para el checklist.

## Verificado ejecutándolo (2026-08-28, su misma cadena: pnpm 11.23.0, TS 7.0.2, Node 24.18.0, Terraform 1.15.8)

1. **La trampa de las parameter properties me mordió a mí** al escribir el fake y el
   adaptador: `ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX`, exactamente como documenta LR-0011. Todo el
   código de la lección va con campo + asignación explícita, y el adaptador lleva el
   comentario del porqué.
2. **Tamaños**: bundle con zod + `@aws-sdk/client-dynamodb` = 835 728 B (el SDK añade
   ~508 KB, coherente con los 504 422 B medidos solos en LR-0011). Zip: 216 388 B, ×3,3 sobre
   los 65 437 de la lección 06. Munición para la apuesta del `Init Duration`, que **sigue sin
   cobrarse** — la lección la reclama en la cabecera y en el cierre.
3. **`terraform validate` + `fmt`** limpios con la tabla, la política `put-links`, el bloque
   `environment` y el output `table_name` (con `type = string`, como los demás).
4. **Precios y límites verificados** contra la Price List API y la doc (2026-08-28):
   on-demand 0,625/0,125 USD por millón de WRU/RRU; 25 GB-mes de almacenamiento gratis, luego
   0,25; provisionado 0,00065/0,00013 USD por unidad-hora; ítem 400 KB; clave de partición
   2048 B, de ordenación 1024 B; 3 000 RRU / 1 000 WRU por partición física; página de
   Query/Scan 1 MB; 20 GSI; 2 500 tablas/región.

## El bug que él encontró desplegando, y la lección para mí (añadido el mismo día)

Al invocar tras el `apply`: `Dynamic require of "node:https" is not supported`, en el
`ModuleJob.run` del runtime. Causa: parte del SDK es CommonJS; esbuild a ESM convierte sus
`require` en un stub que usa un `require` real del ámbito del módulo si existe — y en un
`.mjs` cargado por Lambda no existe. **Mi verificación de humo pasaba porque importaba el
bundle desde `node -e` (contexto CJS), donde el stub sí encuentra `require`.** Reproducido en
limpio con un `run.mjs` (misma traza exacta que la suya) y arreglado con
`--banner:js="import { createRequire } from 'node:module'; const require = createRequire(import.meta.url);"`
en el build (+93 bytes); tras el banner, el bundle en ESM puro llega hasta la resolución de
credenciales. Añadido a la lección 07 como callout de trampa, con la parte del portátil que
miente incluida.

**Regla operativa nueva: las pruebas de humo de un bundle ESM se ejecutan desde un fichero
`.mjs`, jamás desde `node -e` ni desde un contexto CJS.**

También tuvo que añadir `dynamodb:*` a la política del usuario `terraform` en
`00-foundations/iam.tf` — bien hecho y en el sitio correcto, pero la lección no lo avisaba:
**toda lección que estrene un servicio debe abrir con el recordatorio de ampliar la política
del proyecto 00.**

## Decisiones de enseñanza que sientan precedente

- **La API nativa antes que `lib-dynamodb`**: el `{ S: … }` desnudo enseña el tipado de
  DynamoDB, y para dos atributos el DocumentClient sería una dependencia sin motivo. Se
  reevalúa en el proyecto 02 con ítems de verdad — dicho así en la lección, con fecha, como
  manda el precedente de LR-0011.
- **La corrección de «dos acciones»**: la lección 06 anunció que la política crecería con dos
  acciones; son una (`PutItem`). Corregido en la propia lección, en voz alta, aplicando
  «agrupa por permisos»: la llave de `GetItem` es de la función que redirige, que no existe.
- **La verificación de hoy es el `get-item`, no el 200**: la Lambda de la lección 05 también
  devolvía 200 y no guardaba nada. Sigue el precedente de LR-0003 — la prueba va a buscar el
  efecto, no la respuesta.
- **La dependencia implícita cruza por primera vez la frontera infra → aplicación**
  (`TABLE_NAME = aws_dynamodb_table.links.name`): un argumento con dos trabajos, inyección de
  configuración y arista del grafo. El `depends_on` de la política sigue siendo explícito
  porque ninguna referencia lo cuenta — buen par mínimo para distinguir ambos casos.

## Señales a vigilar

- **La pregunta del cierre es deliberadamente incómoda**: «el fake, ¿prueba de verdad o huele
  a trampa?». Si contesta que huele a trampa, la respuesta buena no es defender el fake, sino
  darle la razón a medias: el fake prueba la *política* de reintento, no la *atomicidad* — esa
  la garantiza la condición, y solo el despliegue la toca. Esa distinción es la lección.
- **La apuesta del Init Duration lleva dos lecciones sin cobrarse.** Si tampoco trae las
  líneas `REPORT` esta vez, en la lección 08 hay que pedírselas como primer paso, no como
  nota al pie — o retirar la apuesta explícitamente para no normalizar promesas que caducan.
- Quedó **PITR apagado a sabiendas** y dicho en «esto no lo demuestra»: si algún día pregunta
  por backups, la ficha tiene los precios y ese hueco es el gancho.

## Qué se escribió

- `lessons/0007-la-memoria-del-acortador.html` — la lección.
- `reference/aws-dynamodb.html` — ficha nueva, con el modelado single-table como hueco
  deliberado ofrecido en el `.ask`.
- ROADMAP (fila 07), `reference/README.md`, GLOSSARY (6 términos nuevos en pendientes).
