# Ejercicio 04 — La cadena de invocación

> Dificultad ●●○ · ~60-90 min · Servicios: Lambda ×2, IAM, CloudWatch Logs
> Prerequisito: [lección 06](../../lessons/0006-el-zip-no-es-tu-repositorio.html)

## Contexto

No todo pasa por una puerta pública. Dentro de un sistema, un servicio llama a otro
constantemente: el que recibe pedidos llama al que valida direcciones, el que factura
llama al que calcula impuestos. En serverless, la versión mínima de eso son **dos Lambdas
donde una invoca a la otra** — y la pregunta interesante no es el código, es la de
siempre: ¿con qué identidad llama, quién se lo permite, y sobre qué recurso exactamente?

Hasta hoy el único principal que invocaba tus funciones era... nadie (las invocabas tú
por CLI). Hoy el invocador es **otra Lambda**, y eso convierte a la función en el
*recurso* de una política por primera vez desde el lado del que llama.

## Lo que vas a construir

- `practice-04-greeter`: recibe `{ "name": "..." }`, y llama a la otra para componer su
  respuesta.
- `practice-04-normalizer`: recibe un nombre y devuelve su forma canónica (trim, colapso
  de espacios, capitalización simple). Sin dependencias: TypeScript puro.
- El permiso **exacto** para que greeter pueda invocar a normalizer — y a nadie más.

La lógica es trivial a propósito. El ejercicio es el cableado: dos grafos de recursos,
dos roles, una arista IAM entre ellos, y el SDK de Lambda cruzando de un lado a otro.

## Requisitos obligatorios

1. Backend remoto, key propia. Un solo directorio de Terraform para las dos funciones,
   con los `.tf` partidos por componente, como refactorizaste el proyecto 01.
2. **Dos roles distintos.** Prohibido un rol compartido: agrupa por permisos. El de
   normalizer no sabe que greeter existe.
3. El permiso de invocación va en la política de identidad de greeter, con `resources`
   apuntando al ARN de normalizer **por referencia** (nada escrito a mano).
4. El nombre de la función destino llega a greeter por **variable de entorno** poblada
   por referencia — la dependencia implícita cruzando la frontera infra → aplicación,
   como `TABLE_NAME` en la lección 07.
5. Los dos log groups los crea Terraform, retención 7 días, y cada rol escribe **solo**
   en el suyo.
6. Cadena de build de siempre (pnpm 11, TS 7, esbuild, ESM, arm64) y **prueba de humo
   desde un `.mjs`** para greeter — ya sabes por qué esa regla existe.
7. Tests de la lógica de normalización ejecutables **sin AWS** (`node --test`). Dónde
   pones la frontera para lograrlo es decisión tuya — la defenderás en la revisión.

## Restricciones

- Invocación **síncrona** (RequestResponse). La asíncrona y las colas son del proyecto 02.
- Nada de API Gateway aquí.
- Coste: ~0.

## Verificación — esto lo demuestra, esto no

```sh
# La cadena entera funciona (y la respuesta viene compuesta por las DOS funciones)
aws lambda invoke --function-name practice-04-greeter \
  --cli-binary-format raw-in-base64-out \
  --payload '{"name":"  aDa   lovelace "}' out.json --profile personal
cat out.json   # → algo como {"greeting":"Hola, Ada Lovelace"}

# Las dos funciones dejaron rastro cada una en SU log group
aws logs filter-log-events --log-group-name /aws/lambda/practice-04-greeter ...
aws logs filter-log-events --log-group-name /aws/lambda/practice-04-normalizer ...

# Y la parte que casi todos se saltan: el privilegio es mínimo DE VERDAD.
# Invocar normalizer directamente con el rol de... espera: ¿puedes demostrar
# que greeter NO puede invocar otra cosa? Piensa qué prueba negativa está a tu
# alcance y ejecútala. En la revisión me cuentas cuál elegiste y qué demuestra.
```

El `out.json` con 200 no demuestra que normalizer corrió: greeter podría haber
normalizado él mismo. **Los logs de normalizer son la prueba del viaje.**

Cierre: `terraform destroy` y comprueba que no queda ni función ni log group huérfano
(ya sabes quién crea log groups a escondidas cuando tú no los declaras).

## Antes de empezar

Nada que ampliar: `lambda:*`, `iam:*` y `logs:*` ya están en tu política.

## Pistas

- El SDK que necesita greeter para invocar es un cliente más, como el de DynamoDB en la
  lección 07 — y trae los mismos compañeros de viaje: peso en el bundle y aquel problema
  del `require` en ESM que ya te mordió una vez.
- El `Payload` que devuelve el SDK de Lambda no es un string. Mira el tipo antes de
  hacerle `JSON.parse` a lo loco.
- Un `AccessDenied` al invocar en cadena es un regalo: dice qué principal, qué acción y
  qué recurso. Léelo entero antes de tocar la política — cada error de estos enseña una
  arista del grafo.
- El ARN del log group y el `:*`: tercera vez en el curso. Que no te pille la cuarta.

## Dónde investigar

- [Ficha Lambda](../../reference/aws-lambda.html) — «por qué son cuatro recursos y no
  uno»; aquí son ocho, mismo grafo dos veces.
- [Ficha TypeScript en Lambda](../../reference/typescript-lambda.html) — capas, tamaños,
  humo en `.mjs`.
- AWS: [invocación síncrona](https://docs.aws.amazon.com/lambda/latest/dg/invocation-sync.html) ·
  [`@aws-sdk/client-lambda`](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/lambda/)
- Provider: [`aws_lambda_function`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/lambda_function.html.markdown)

---

*¿Atascado de verdad (30+ min sin avanzar)? Pregúntame en el chat — orientar no es resolver.*
