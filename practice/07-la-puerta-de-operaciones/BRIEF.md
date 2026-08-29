# Ejercicio 07 — La puerta de operaciones

> Dificultad ●●● · ~90 min · Servicios: API Gateway HTTP, Lambda, DynamoDB
> Prerequisitos: ⚠️ **[lección 08](../../lessons/0008-la-puerta-publica.html) cursada** ·
> recomendable el [ejercicio 03](../03-el-candado-de-despliegue/BRIEF.md)

## Contexto

Tu equipo quiere un registro central de despliegues: cada vez que algo se despliega, el
sistema que despliega hace `POST /deploys` a un webhook interno y queda constancia de
qué, quién y cuándo. El requisito que lo hace interesante no es guardar — es que los
sistemas de CI **reintentan**: el mismo evento puede llegar dos, tres veces. La palabra
de entrevista de hoy es **idempotencia**: recibir el mismo `POST` dos veces y que la
segunda no haga daño ni mienta.

Es la arquitectura del acortador —puerta, cerebro, memoria— construida entera por ti,
con semántica distinta. Ahí se ve si era tuya o de la lección.

## Lo que vas a construir

- API HTTP `practice-07-ops` con la ruta `POST /deploys`.
- Lambda `practice-07-record-deploy` (TypeScript, capas como las del acortador).
- Tabla `practice-07-deploys`, clave de partición `deploy_id`.

Contrato:

| Caso | Respuesta |
|---|---|
| `{"deploy_id":"d-42","service":"api","author":"carlos"}` nuevo | `201` + lo guardado |
| El mismo `deploy_id` otra vez | `409` + `{"error":"deploy d-42 already recorded"}` |
| Body inválido (sin `deploy_id`, no-JSON, etc.) | `400` + motivo |
| Cualquier otra explosión | `500` auténtico |

## Requisitos obligatorios

1. Backend remoto, key propia.
2. `payload_format_version` **explícito** y en `"2.0"`. Ya sabes por qué no se calla uno
   ese argumento.
3. El `aws_lambda_permission` con `source_arn` acotado a **esta** API — no un permiso
   universal a todo API Gateway.
4. La escritura es **una sola operación condicional**: nada de leer-y-luego-escribir. El
   409 nace de la excepción de condición, traducida en su sitio.
5. Disciplina de capas del acortador: la forma del payload se valida donde toca, el
   handler traduce protocolo (sobre 2.0 → dominio → respuesta HTTP), los errores
   esperados se traducen, los imprevistos se relanzan. Tests sin AWS de la validación y
   del caso de uso (incluida la colisión → su error tipado).
6. **Throttling configurado en el stage**: pon un límite bajo (p. ej. rate 2, burst 2) y
   **demuéstralo** con un bucle de `curl` hasta ver el `429`. Es tu primera arma contra
   la factura sorpresa en una API pública, y la lección 08 la dejó solo nombrada.
7. La verificación del efecto, como siempre: el `get-item` tras el 201, y tras el 409 la
   prueba de que el ítem **no cambió** (el timestamp original sigue).

## Restricciones

- Una sola ruta. Ni `GET`, ni `for_each`, ni segunda función: eso es la lección 09 y no
  se la vamos a destripar.
- Sin authorizer: la puerta queda abierta a sabiendas, dilo en tu README como hizo la
  lección 08 (y nombra qué pieza faltaría).
- Coste: ~0 (free tier de API Gateway aparte — tu cuenta es de 2026, revisa si te aplica
  todavía y anótalo: es el único free tier del curso que caduca).

## Verificación — esto lo demuestra, esto no

```sh
URL=$(terraform output -raw api_url)

curl -si -X POST "$URL/deploys" -H 'content-type: application/json' \
  -d '{"deploy_id":"d-42","service":"api","author":"carlos"}'   # → 201
# repite el MISMO comando                                        # → 409
curl -si -X POST "$URL/deploys" -d '{"service":"api"}'          # → 400
for i in $(seq 1 20); do curl -s -o /dev/null -w '%{http_code}\n' \
  -X POST "$URL/deploys" -d '{"deploy_id":"d-'$i'","service":"x","author":"y"}'; done
                                                                 # → aparecen 429

aws dynamodb get-item --table-name practice-07-deploys \
  --key '{"deploy_id":{"S":"d-42"}}' --profile personal          # → 1 ítem, timestamp intacto
```

El 201 no demuestra que se guardó, el 409 no demuestra que no se machacó: **el
`get-item` demuestra las dos cosas.** Y si el 500 aparece con los logs vacíos, ya sabes
qué heurística aplicar y qué pieza mirar primero.

Cierre: `terraform destroy` completo y verificado (API, función, rol, log group, tabla).

## Antes de empezar

`apigateway:*` debería estar ya en tu política si cursaste la lección 08 — compruébalo
antes del primer `apply`, no después del primer 403.

## Pistas

- Las cinco piezas de la puerta las tienes frescas. La novedad de hoy está en el stage:
  busca cómo se configuran los límites de las rutas por defecto. El `validate` con un
  valor inventado te enumera opciones si algún argumento de lista cerrada se te resiste.
- El `deploy_id` viene del cliente y la clave de partición es una decisión: ¿qué pregunta
  responde esta tabla? Compárala con la del acortador antes de escribir el `attribute`.
- El 409 y el 400 son primos pero no hermanos: uno es «me lo pediste bien y ya estaba»,
  el otro «me lo pediste mal». Si los dos salen del mismo `catch`, la frontera de capas
  está torcida.
- El bucle del 429: el throttling de API Gateway es de ventana corta — si no aparece,
  dispara más rápido (`&` al final del curl, o baja el rate a 1).

## Dónde investigar

- [Ficha API Gateway del curso](../../reference/aws-apigateway.html)
- AWS: [throttling en HTTP APIs](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-throttling.html)
- Provider: [`aws_apigatewayv2_stage`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/apigatewayv2_stage.html.markdown) ·
  [`aws_apigatewayv2_api`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/apigatewayv2_api.html.markdown) ·
  [`aws_lambda_permission`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/lambda_permission.html.markdown)

---

*¿Atascado de verdad (30+ min sin avanzar)? Pregúntame en el chat — orientar no es resolver.*
