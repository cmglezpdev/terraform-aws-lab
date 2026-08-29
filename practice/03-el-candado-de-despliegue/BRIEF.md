# Ejercicio 03 — El candado de despliegue

> Dificultad ●●○ · ~60 min · Servicios: DynamoDB
> Prerequisito: [lección 07](../../lessons/0007-la-memoria-del-acortador.html)

## Contexto

Tu backend S3 usa un `.tflock` para que dos `apply` no pisen el mismo state. Ese patrón
—**adquirir un candado con nombre, y que el segundo en llegar falle**— es de los más
reutilizados en sistemas distribuidos: despliegues, cron jobs que no deben solaparse,
migraciones. Hoy lo implementas tú, con DynamoDB, y sin una línea de Lambda: la
consola de este ejercicio es la AWS CLI.

De paso vas a mirar de frente la trampa de la lección 07: `PutItem` no inserta,
**reemplaza**. Primero te va a machacar un candado en silencio; luego lo vas a impedir.

## Lo que vas a construir

Una tabla `practice-03-locks` y un pequeño protocolo sobre ella, ejecutado a mano:

1. **Adquirir**: escribir el ítem `{lock_id, owner, acquired_at}` — solo si nadie lo tiene.
2. **Colisionar**: un segundo «proceso» (tú, con otro `owner`) intenta adquirir el mismo
   `lock_id` y **debe fallar** con error de condición, no sobrescribir.
3. **Liberar**: borrar el candado — pero solo si el `owner` que libera es el que lo
   adquirió. Liberar el candado de otro también debe fallar.

## Requisitos obligatorios

1. Backend remoto, key propia. La tabla, en Terraform; el protocolo, en CLI.
2. `billing_mode` **escrito explícitamente**, aunque elijas el que elegirías igualmente.
   En el README de tu solución: una frase sobre por qué el default del provider aquí no
   es tu default.
3. Antes de proteger nada, **demuestra el problema**: adquiere el candado con `owner=ana`,
   vuelve a escribirlo con `owner=eva` sin condición, y enseña con `get-item` que el
   candado de ana desapareció sin que nadie diera error. Guarda esa secuencia: es la
   mitad del valor del ejercicio.
4. Adquisición y liberación protegidas con expresiones de condición — una de existencia
   y una de igualdad, respectivamente.
5. Los comandos del protocolo (adquirir / colisionar / liberar / liberar-ajeno) quedan en
   un `protocol.md` o script comentado dentro de la carpeta: reproducibles, no de memoria.

## Restricciones

- Sin Lambda, sin código TypeScript. CLI pura.
- Sin sort key, sin GSI, sin TTL: la clave de partición sola da para todo el ejercicio.
- Coste: ~0 (on-demand, decenas de operaciones).

## Verificación — esto lo demuestra, esto no

```sh
# La colisión falla con el error correcto (y no con AccessDenied ni ValidationException)
aws dynamodb put-item ... # → ConditionalCheckFailedException

# El candado sobrevive intacto al intento fallido
aws dynamodb get-item --table-name practice-03-locks --key '{"lock_id":{"S":"deploy-prod"}}'

# Liberar con el owner equivocado falla; con el correcto, borra
aws dynamodb delete-item ... # las dos variantes
```

Un `put-item` que responde sin error **no demuestra nada** — esa es exactamente la
lección. Lo que demuestra es el `get-item` posterior: el efecto, no la respuesta.

Cierre: `terraform destroy` + `aws dynamodb list-tables` para confirmar.

## Antes de empezar

Nada que ampliar: `dynamodb:*` ya está en tu política desde la lección 07.

## Pistas

- La CLI de DynamoDB tiene su propio dialecto para las condiciones y los valores
  (`--condition-expression`, `--expression-attribute-values`). Pelearte con ese JSON
  *es* parte del ejercicio; el formato `{"S": ...}` ya lo conoces del adaptador.
- Cuando la condición falla, DynamoDB puede contarte **qué había** en vez de solo decir
  que no. Hay un flag reciente de la CLI para eso; te ahorra un `get-item` y queda muy
  bien en una revisión.
- Piensa qué pasa si un proceso muere sin liberar su candado. No tienes que resolverlo
  (la herramienta idiomática llega en el proyecto 03), pero tu README debe nombrar el
  problema y qué harías.

## Dónde investigar

- [Ficha DynamoDB del curso](../../reference/aws-dynamodb.html) — la clave, el upsert,
  la escritura condicional.
- AWS: [expresiones de condición](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Expressions.ConditionExpressions.html) ·
  [`put-item` en la CLI](https://docs.aws.amazon.com/cli/latest/reference/dynamodb/put-item.html)
- Provider: [`aws_dynamodb_table`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/dynamodb_table.html.markdown)

---

*¿Atascado de verdad (30+ min sin avanzar)? Pregúntame en el chat — orientar no es resolver.*
