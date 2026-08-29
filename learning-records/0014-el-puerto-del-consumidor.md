# La segunda función: el puerto pertenece al consumidor, y la ausencia no grita

2026-08-29, lección 09. La función de redirección (`GET /{code}` → 301) completa la
funcionalidad del acortador. Dos ideas quedan como vocabulario: **el puerto pertenece al
consumidor** (se declara `LinkFinder` en vez de ensanchar `LinkRepository`) y **la ausencia
no grita** (`GetItem` sin `Item` es un 200 vacío — quinta entrega del hilo del fallo
silencioso). «Agrupa por permisos» pasa de heurística leída a frontera desplegada: el
endpoint anónimo de lectura no tiene la llave de escritura, verificado con
`aws iam list-role-policies`.

## La avería del paso 0 — encontrada leyendo su código, confirmada ejecutándolo

Su `handler.ts` (retranscrito por él tras la lección 08) perdió dos `return`: las ramas de
`ZodError` y `CodeCollisionError` calculaban `json(400, …)` sin devolverlo y caían al
`throw` final → 500. **Confirmado contra su bundle construido** (`dist/index.mjs` lanza
`ZodError` con `{"enlace": …}`): el 500 estaba desplegado. Claves:

- **Su humo de la lección 08 no podía verlo**: probaba el body no-JSON y el `ftp://` — las
  dos ramas sanas. El JSON válido con forma equivocada (la rama coja) no estaba cubierto.
  Moraleja fijada en la lección: *un humo que no cubre todos los contratos jura en falso*.
- La lección abre con el síntoma (`curl` con `{"enlace": …}`) y pistas direccionales, no con
  la respuesta — el diagnóstico es suyo (preferencia de ejercicios sin supervisión). La
  heurística nueva es la inversa de LR-0013: **500 con logs = el fallo está dentro**.
- El arreglo viaja dentro de la reorganización (`handler.ts` → `handlers/create-link.ts`),
  no como parche suelto. `CodeCollisionError` se queda sin `return` **a propósito** (agotar
  reintentos no es culpa del cliente): la lección se lo hace verificar rama a rama.
- **El humo asciende a script permanente del repo** (`app/smoke.mjs` + `pnpm run smoke`, 6
  contratos de los dos bundles) — resuelve el pendiente de LR-0013. `malo.json` jubilado.

## Decisiones de diseño de la lección

- **Puerto segregado en vez de ensanchado.** Añadir `findByCode` a `LinkRepository` habría
  obligado a tocar el fake de `create-link.test.ts` (el compilador manda). `LinkFinder`
  aparte deja el lado de escritura intacto — el `git diff` vuelve a ser el juez. El
  adaptador implementa los dos puertos; es la semilla de CQRS sin nombrarlo.
- **La guarda `isShortCode` vive en el dominio** y es lo que justifica que `getLink` exista
  como caso de uso (el criterio de LR-0011 sigue vivo y la lección lo confiesa): `{code}`
  atrapa cualquier segmento (`/favicon.ico`, `/robots.txt`) y sin guarda cada tontería paga
  un `GetItem`. El test prueba que el fake **no** recibió la llamada (`lookups.length === 0`).
- **«Esto lo demuestra el test, no el curl»** — la frase del curso, invertida por primera
  vez: el no-efecto (404 barato sin tocar la tabla) es indistinguible desde fuera; solo el
  puerto lo ve. El efecto se verifica en el despliegue; el no-efecto, en el test.
- **301 como decisión defendible, no default**: cacheado para siempre por los navegadores —
  gratis y rápido para enlaces inmutables, letal para corregir destinos o contar clics (los
  comerciales usan 302/307 por la analítica). La quiz 2 explota el contador de clics.
- **Dos funciones, no lambdalith**, aplicando «agrupa por permisos» (LR-0011): `PutItem` y
  `GetItem` parten el problema con línea limpia; el radio de daño del endpoint público de
  lectura no incluye escribir.
- **El `for_each` se aplaza por segunda vez, declarado con motivo nuevo**: el refactor bueno
  necesita que los gemelos existan primero (hoy se siente el copia-pega), y pasar recursos a
  `for_each` cambia direcciones en el state → plan de destruir-y-recrear → bloques `moved`.
  Eso es la lección 10 entera («el refactor invisible»), con la quiz 1 dejándole asomado.
  `get-link.tf` lleva la advertencia de gemelo deliberado en su comentario de cabecera.

## Verificado ejecutándolo (2026-08-29, su cadena: pnpm 11.23.0, TS 7.0.2, Node 24.18.0, Terraform 1.15.8)

1. `typecheck` limpio tras la reorganización; **22/22 tests** (14 + 8 del lector); humo de
   los dos bundles desde `.mjs`: 6/6.
2. esbuild multi-entrada: entradas `src/handlers/{create-link,get-link}.ts` +
   `--outdir=dist --out-extension:.js=.mjs` → `create-link.mjs` **836 297 B**,
   `get-link.mjs` **505 748 B**. La diferencia ≈ 330 KB es zod casi al byte (327 893 B en
   LR-0011): *cada artefacto pesa exactamente lo que su handler sabe* — «el zip no es tu
   repositorio», en estéreo.
3. `terraform validate` + `fmt -check` limpios (1.15.8, provider aws ~> 6.0) con el gemelo,
   los locals renombrados (`create_link_function_name`/`get_link_function_name`) y las tres
   piezas nuevas de la puerta. Plan esperado: 8 a crear, 1 a modificar (handler + hash de
   `create_link`).
4. Precedencia de rutas verificada contra la doc el 2026-08-29: variable = un segmento
   exacto; específica > variable > `{proxy+}` (glotona, solo al final) > `$default`.
   `GET /abc/def` no casa → 404 de la puerta.
5. Trampa nueva de la frontera código↔infra: renombrar el bundle exige cambiar
   `handler = "create-link.handler"` — si se olvida, `apply` triunfa y la invocación da
   `Runtime.ImportModuleError`. Mismo género que `payload_format_version`.

## Señales a vigilar

- **La pregunta del cierre** (¿qué decisión hace que `get-link.mjs` pese 330 KB menos?)
  apunta a la lección 06/08: zod vive en `application/` del lado de escritura y el handler
  lector no lo alcanza desde sus imports; esbuild empaqueta por alcance. Si contesta «porque
  no valida payloads», está a medio camino — falta que nombre que fue el *reparto por
  consumidor* (la forma del payload en su caso de uso, no en el dominio compartido) lo que
  evitó que zod fuera transitivo.
- Los tres 404 tienen **dos autores** (dos bodies `error` suyos, un `message` de la puerta)
  — si confunde quién firma cuál, repasar la heurística del log vacío.
- Si pregunta por qué no `Query`/`Scan` o por índices: respuesta corta en el chat, ficha de
  DynamoDB para el material duro (marco de LR-0011: es un curso de Terraform).
- Si el `plan` le sale con más de 9 líneas: lo más probable es un `local.function_name`
  huérfano sin renombrar — Terraform lo chiva en el `validate`.
