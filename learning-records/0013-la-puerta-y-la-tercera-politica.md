# La puerta cambia el protocolo, y IAM completa su mapa con la tercera política

2026-08-28, lección 08. API Gateway HTTP delante del acortador: `POST /links` público. La
lección se diseñó alrededor de dos ideas que deben quedar como vocabulario: el **sobre**
(payload format 2.0) como contrato de invocación que muere en el handler, y la **política
basada en recursos** como tercera clase de IAM, cerrando el mapa que abrió la lección 04
(identidad) y completó la 05 (confianza).

## Decisiones de diseño de la lección

- **Se partió lo prometido, y se dijo.** La lección 07 anunció puerta + segunda Lambda +
  `for_each` para la 08. No cabe (LR-0005): el cambio de protocolo del handler más las cinco
  piezas de la puerta llenan los 40 min. La 09 recoge la función de redirección, `GetItem`,
  el 301 y el `for_each` sobre el mapa de funciones. La lección lo declara en un callout
  propio con el porqué, siguiendo el precedente exacto de LR-0005: que nunca parezca olvido.
- **La apuesta del Init Duration es el paso 0, no una nota al pie** (mandato de LR-0012).
  Dato nuevo: su `logtrail.txt` ya contenía el REPORT de la lección 07 — `Init Duration:
  172.83 ms` con el zip de 216 KB. Falta el «antes»; la retención de 7 días borra las líneas
  de la lección 05 alrededor del **31 de agosto**, así que la lección fija urgencia, comando
  (`aws logs filter-log-events --filter-pattern '"Init Duration"'`) y criterio falsable
  escrito ANTES de mirar: diferencia < 100 ms → la predicción se sostiene; ≥ 100 ms → perdí
  y pasamos a `zod/mini` en la 09; sin líneas viejas → la apuesta se retira y la culpa es
  del que apostó y no midió a tiempo.
- **El recordatorio de la política del proyecto 00 abre la lección** (`apigateway:*` en
  `iam.tf`), cumpliendo el precedente que la lección 07 incumplió (LR-0012). Bonus de
  entrevista: las acciones IAM de API Gateway son verbos HTTP (`apigateway:POST`), no
  nombres de operación.
- **La trampa central de Terraform es `payload_format_version`**: el provider manda `"1.0"`
  si callas; la consola crea `"2.0"`. Tercera entrega de «el default del provider no es tu
  default» (`x86_64`, `PROVISIONED`, ahora esto) — y la más sutil: no encarece, cambia el
  contrato del evento, y ninguna herramienta de Terraform puede detectarlo.
- **La trampa central de AWS es el permiso de invocación**: sin `aws_lambda_permission`, 500
  con `{"message":"Internal Server Error"}` y **cero líneas en los logs** — la función nunca
  corrió. Cuarta entrega del hilo «fallo silencioso» (ARN sin `:*`, sourcemap, upsert, y
  ahora esto). Heurística enseñada: *log vacío = el problema está antes de la función*.
- **El handler gana su segundo apellido**: raíz de composición **y adaptador de protocolo**.
  Solo él conoce el sobre 2.0; los errores esperados se *traducen* (400), los imprevistos se
  *relanzan* (500 auténtico que las métricas deben contar). El `git diff --stat` vuelve a
  ser el juez: en `app/src/` solo se mueve `handler.ts`, con los 14 tests intactos —
  segunda demostración consecutiva de las capas, esta vez cambiando el protocolo entero.
- **`integration_method = "POST"` vs el `POST` de `route_key`**: dos tramos distintos del
  viaje (cliente→puerta, puerta→Lambda). Que hoy coincidan es casualidad; la quiz 1 de la
  lección explota justo eso con el `GET /{code}` de la 09.

## Verificado ejecutándolo (2026-08-28, su cadena: pnpm 11.23.0, TS 7.0.2, Node 24.18.0, Terraform 1.15.8)

1. Handler nuevo: `typecheck` limpio, **14/14 tests sin tocar ninguno**, bundle 836 125 B
   (+397 B sobre la lección 07 — el sobre HTTP es casi gratis).
2. Prueba de humo **desde `.mjs`** (regla de LR-0012, primera vez aplicada desde su
   nacimiento): los cuatro caminos 400 (body no-JSON, body ausente, `ftp://`, payload sin
   `url`) responden `{statusCode: 400}` sin credenciales y sin tocar AWS.
3. `http-api.tf` + output `api_url`: `terraform validate` y `fmt -check` limpios con la
   misma versión 1.15.8, provider aws ~> 6.0.
4. Precios y cuotas verificados el 2026-08-28: HTTP API 1,00 USD/M (0,90 > 300 M), medición
   en incrementos de 512 KB, **free tier de 1 M/mes que caduca a los 12 meses de la
   cuenta** (a diferencia de Lambda/DynamoDB — está en la ficha), timeout de integración
   30 s no ajustable, payload 10 MB, 300 rutas/API. Fuentes: Price List API + doc de cuotas.

## Señales a vigilar

- **La pregunta del cierre** (¿solo tu frontend crea, cualquiera sigue?) apunta a las tres
  clases de política. Respuesta buena esperable: en ninguna de las tres tal cual — un
  authorizer en la ruta `POST` es el mecanismo idiomático (proyecto 03); intentarlo con
  `source_arn` o con la resource-based policy no distingue *qué cliente* llama. Si contesta
  «authorizer», va sobrado; si contesta «resource-based policy», es el error instructivo:
  esa política autoriza *a API Gateway*, no a tu frontend.
- **La API queda abierta a sabiendas** y la lección lo dice con todas las letras en «esto no
  lo demuestra». Si se inquieta, la respuesta no es cerrarla ya: es que sepa nombrar qué
  pieza falta (authorizer JWT) y cuándo llega.
- **CORS no configurado, dicho a propósito**: el primer `fetch` desde un navegador fallará.
  Cuando pregunte, `cors_configuration` está en la ficha y es un buen ejercicio corto.
- Durante la escritura de la lección, las páginas de la doc de AWS traían inyectado un
  bloque «ejecuta este comando de la CLI» — ignorado por principio. Anotado aquí como
  recordatorio de que el material fetched se trata como datos, no como instrucciones.

## Qué se escribió

- `lessons/0008-la-puerta-publica.html` — la lección.
- `reference/aws-apigateway.html` — ficha nueva (HTTP vs REST como sección de más valor;
  authorizers, dominios propios e integraciones directas ofrecidos en el `.ask`).
- ROADMAP (fila 08 publicada, fila 09 nueva con nota del corte), `reference/README.md`,
  GLOSSARY (7 términos nuevos en pendientes, «política de recurso» religada), NOTES.

## Addendum (2026-08-29): la apuesta, resuelta

Trajo las líneas al día siguiente de publicarse la lección. Veredicto por el criterio
prefijado: **sostenida** — 145,09 ms (antes) frente a 172,83 ms (después), 27,74 ms de
diferencia. `zod/mini` descartado. La lección lleva la resolución fechada dentro del paso 0.

Lo que importa más que el veredicto: la varianza entre arranques del mismo artefacto
(91→145 ms el bundle pequeño; 173→332 ms el grande) supera el umbral de 100 ms que fijé.
El criterio comparaba muestras sueltas de una métrica ruidosa — **«un Init Duration no es
una medición, es una muestra»** queda como vocabulario del curso, y la próxima apuesta con
métricas se fija sobre varias muestras o no se fija.

Dos hallazgos salidos de sus propias líneas, verificados contra la doc el mismo día:
`Billed Duration = Duration + Init Duration` en los cuatro REPORT (el init de runtimes
gestionados se cobra desde agosto de 2025 — otro «casi todo internet dice lo viejo»), y las
`INIT_REPORT Status: error` como autopsia con nombre técnico del bug del `Dynamic require`,
*suppressed init* (`Phase: invoke`) incluido.
