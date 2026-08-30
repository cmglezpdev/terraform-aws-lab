# La señal: el bus que no retiene, el espía que enseña el contrato, y el grafo hecho visible

2026-08-30, lección 11 — abre el proyecto 02. S3 publica «Object Created» al bus por
defecto de EventBridge, una regla filtra por bucket y sufijo `.csv`, y el primer target no
es el pipeline: es un **espía** (log group) cuyo único trabajo es enseñar el JSON real del
evento. Dos ideas quedan como vocabulario: **el bus enruta, no retiene** (entrega con
reintentos o descarta — la durabilidad es de la cola, no del bus) y **el grafo de
dependencias** — el orden del `apply` son tus propias referencias, y hoy se miró tanto una
flecha como un hueco.

## Decisiones de diseño de la lección

- **El espía antes que el consumidor, con argumento de método**: todo lo que viene (patrón
  afinado, código del procesador, sus tests) se escribe contra la forma del evento, y esa
  forma debe ser un log leído, no un ejemplo de la doc. Enlaza directo con el bug del humo
  de la 07 (la prueba escrita contra un evento imaginado). El JSON que capture es el
  fixture de los tests de la lección 13 — pedírselo y guardarlo.
- **Verificación en positivo y en negativo**: sube un `.csv` (aparece) y un `.txt` (no
  aparece, tras `sleep 60`). Cuarta entrega de «la ausencia no grita» (lección 09): en un
  sistema asíncrono el no-efecto hay que salir a buscarlo. El minuto de espera es parte de
  la prueba.
- **La tercera pata del mapa IAM, reutilizada tal como se prometió en LR-0013**:
  `aws_cloudwatch_log_resource_policy` presentada como «lo que `aws_lambda_permission` fue
  a la función». El `:*` que falta en el ARN del log group (trampa central de la 05)
  reaparece y la lección lo dice antes de que muerda. Sexto «fallo silencioso» del curso:
  target sin política de recurso = apply limpio + silencio.
- **Dependencia implícita enseñada con el hueco, no solo con la flecha**: la política del
  log group y el target no se referencian → no hay arista → no hay orden garantizado. Hoy
  es benigno (la política no es requisito de *creación*, solo de *entrega*, y la primera
  entrega llega minutos después), y decir *por qué* es benigno es la mitad de la lección.
  `depends_on` queda **plantado con nombre** para la 12 (la cola), igual que la 10 plantó
  `count`. No usarlo hoy donde no hace falta fue deliberado: enseñarlo sobre un caso
  postizo gastaría el caso real.
- **El corte del proyecto 02 declarado en la primera tabla** (LR-0005): 11 señal, 12 cola,
  13 procesador (+ módulo local «si duele donde predijimos» — la cláusula de salida del
  ROADMAP sigue viva), 14 aviso. «Los números pueden correrse; el orden no.»
- **La política del 00 se amplía con un statement `ProjectBuckets`**
  (`arn:aws:s3:::event-driven-*` y `/*`), no relajando el `s3:*` global: los dos ARNs de S3
  (lección 04) trabajando de frontera por prefijo de nombre. El bucket usa
  `data.aws_caller_identity` para ser único sin escribir el ID de cuenta en un repo
  público — mismo data source que `alerts.tf` del 00, ahora con nombre de concepto.
- **`force_destroy = true` con la advertencia pegada**: bucket de pruebas, jamás en datos
  reales.
- La pregunta del cierre (Lambda caída 6 h, 20 CSV subidos, sin cola): respuesta buena
  esperable — **los 20 objetos siguen en S3** (el dato nunca corrió peligro), los 20
  eventos están *anotados* en el log del espía, pero como señal procesable se evaporaron:
  nada los reentrega, y «reprocesar» hoy significaría re-subir o leer el bucket a mano.
  Distinguir dato (durable en S3) de señal (efímera en el bus) es exactamente la
  motivación de la 12. Si responde «se pierden los CSV», frenar ahí.

## Verificado ejecutándolo (2026-08-30, Terraform 1.15.8, provider aws 6.62.0)

1. El HCL completo de la lección (bucket + notification + regla + log group + política +
   target) validado en local: `terraform validate` y `fmt -check` limpios; `jsonencode`
   con la clave `detail-type` produce el JSON correcto (comprobado en `terraform console`).
2. Precios contra la Price List API (`AWSEvents`, us-east-1, 2026-08-30): eventos de
   servicios AWS al bus por defecto **sin SKU de ingesta** (gratis, confirmado por la
   página de precios: «AWS management events are ingested by the event bus for free»);
   custom/partner 1,00 USD/M en trozos de 64 KB; entrega misma cuenta sin cargo.
3. Doc verificada: `eventbridge = true` único por bucket y machaca lo existente (provider);
   target a log group sin `role_arn` + resource policy con `events.amazonaws.com` y
   `delivery.logs.amazonaws.com` (provider); estructura del evento «Object Created» y
   campos del `detail` (guía de S3); operadores `suffix`/`prefix`/`anything-but` (guía de
   EventBridge); RetryPolicy máx. 24 h / 185 intentos (API Reference); cuotas: 5
   targets/regla **no ajustable**, 300 reglas/bus, patrón 2 048 chars, evento 256 KB.
4. `is_enabled` deprecado a favor de `state` — anotado en la ficha como «casi todo internet
   lleva el viejo», tercera entrega de ese patrón (DynamoDB lock, pnpm, init billing).

## Señales a vigilar

- **Si su `tail` del negativo muestra el `.txt`**: o el patrón divergió al transcribir
  (sufijo, nombre del bucket) o está mirando eventos viejos — pedir el `--since` exacto
  antes de tocar nada.
- **Si pregunta por qué no filtramos en el bucket**: la respuesta corta es que
  `eventbridge = true` no admite filtro y esa es la gracia (el filtrado es del consumidor,
  en su regla); la larga está en la ficha (tabla clásica vs bus).
- **La pregunta de los 20 CSV es el examen real de la lección**: mide si distingue dato de
  señal. Su respuesta decide cómo se abre la 12.
- Divergencias del proyecto 01 aún sin defender (302 vs 301, `CodeCollisionError` → 400):
  siguen listadas en «lo que viene» de la lección; no dejarlas caducar.

## Qué se escribió

- `lessons/0011-la-senal.html` — la lección.
- `reference/aws-eventbridge.html` — ficha nueva (skill `aws-service-explainer`), con
  precios y cuotas fechados 2026-08-30.
- ROADMAP (fila 11 publicada, fila 12 por diseñar, nota del corte del 02),
  `reference/README.md`, GLOSSARY (dependencia implícita/grafo religados a la 11 +
  vocabulario EventBridge en pendientes), NOTES.
