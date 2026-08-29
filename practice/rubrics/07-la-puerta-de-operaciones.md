# Rúbrica 07 — La puerta de operaciones

> **No leer antes de la revisión.**

## Checklist

- [ ] Las cinco piezas de la puerta + `payload_format_version = "2.0"` explícito.
- [ ] `aws_lambda_permission` con `source_arn` = `"${aws_apigatewayv2_api.X.execution_arn}/*/*"`
      (o más fino por stage/ruta). Sin `source_arn` = permiso universal → incumple el
      requisito 3 aunque funcione.
- [ ] `PutItem` con `attribute_not_exists(deploy_id)`; el 409 nace de
      `ConditionalCheckFailedException` traducida. Si hay un `GetItem` previo «para
      comprobar», es la carrera del ejercicio 03 otra vez — pregunta obligada.
- [ ] Capas: dominio/validación testeables sin AWS; colisión con error tipado propio
      (equivalente a `CodeCollisionError`); handler como raíz de composición + adaptador
      de protocolo; 400/409/500 en el sitio correcto (409 desde el caso de uso traducido
      en el handler; 400 desde la validación; 500 = relanzar).
- [ ] Throttling en `default_route_settings` del stage (`throttling_rate_limit` /
      `throttling_burst_limit`) y el 429 **capturado de verdad**.
- [ ] Timestamp intacto tras el 409, demostrado con los dos `get-item`.
- [ ] README con la puerta-abierta-a-sabiendas + nombre de la pieza que falta
      (authorizer) + nota del free tier con su caducidad a los 12 meses.
- [ ] Destroy completo verificado, sin log group huérfano.

## Trampas que espero

- **Las cuatro clásicas reunidas** — este ejercicio es el examen del hilo «fallo
  silencioso» completo: `payload_format_version` callado (sobre 1.0 → su parseo del
  body revienta raro), `aws_lambda_permission` ausente (500 + logs vacíos), upsert sin
  condición (409 nunca llega, el timestamp se machaca), ARN de logs sin `:*` (función
  muda). Cualquiera que pise, lo importante es el diagnóstico con las heurísticas del
  curso (log vacío = el problema está antes de la función).
- El **409 vs 400 desde el mismo catch**: si `ZodError` y su error de colisión caen en el
  mismo manejador genérico, la frontera está torcida (pista 3 lo avisaba).
- El body en el sobre 2.0 puede venir **base64** (`isBase64Encoded`) según cómo dispare
  curl los headers; el acortador ya lo manejaba — ¿lo trajo consigo o lo perdió al
  reconstruir?
- El 429 que no aparece por disparar despacio — si se rindió y lo quitó, LR-0003: la
  alarma sin probar no existe.
- Guardar el timestamp generándolo en el handler vs en el caso de uso — cualquiera vale,
  pero que sepa dónde lo puso y por qué (reloj = efecto, mismo género que `randomBytes`).

## El listón

Este es el capstone: la arquitectura del acortador reproducida **sin mirar el proyecto 01
más que para desatascarse**, con semántica propia (idempotencia ≠ unicidad de código
aleatorio: aquí la clave viene del cliente y la colisión es el caso *esperado*, no el
excepcional — si articula esa diferencia, la lección 07-08 está consolidada de verdad).

## Preguntas de la revisión

1. «¿Tu `POST /deploys` es idempotente? Defínelo sin la palabra "idempotente".» (repetir
   la petición no cambia el estado ni el resultado observable más allá del código de
   respuesta; el 409 es información, no efecto).
2. «¿Por qué el 409 no es un 500, si sale de una excepción?» (error *esperado* del
   contrato → se traduce; el 500 es para lo imprevisto — la distinción de la lección 08).
3. «El throttling que pusiste, ¿a quién protege y de quién? ¿Qué NO te protege?» (protege
   tu factura/Lambda del volumen; no autentica — un atacante lento sigue entrando; la
   pieza que falta es el authorizer, proyecto 03).
4. «¿Qué pasa si dos CI hacen el mismo POST exactamente a la vez?» (la condición decide
   dentro de DynamoDB: uno 201, otro 409 — atomicidad del ejercicio 03, ahora con dos
   clientes de verdad).
