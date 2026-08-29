# Ejercicio 05 — El artefacto desde S3

> Dificultad ●●○ · ~60-90 min · Servicios: Lambda, S3, IAM
> Prerequisitos: [ejercicio 02](../02-el-bucket-de-artefactos/BRIEF.md) (el bucket debe
> existir) · [lección 06](../../lessons/0006-el-zip-no-es-tu-repositorio.html)

## Contexto

Hasta hoy tus Lambdas se despliegan con `filename`: el zip viaja de tu portátil a AWS en
cada `apply`. Funciona… mientras el único portátil sea el tuyo. Con CI, o con un equipo,
el artefacto se construye una vez, se **publica** en un sitio con memoria, y desde ahí se
despliega — y ese sitio ya lo construiste: tu bucket de artefactos versionado.

El premio de este ejercicio es la palabra que más te va a lucir en una entrevista de las
que salen de aquí: **rollback**. Volver a la versión anterior sin recompilar nada, en
segundos, cambiando un valor.

## Lo que vas a construir

Una función `practice-05-echo` (devuelve `{version, echo}` — trivial a propósito, con una
constante `BUILD_VERSION` visible en la respuesta) cuyo despliegue viene **del bucket del
ejercicio 02**, no de un fichero local. Y el ciclo completo:

1. build v1 → publicar al bucket → `apply` → invocar → responde v1
2. build v2 → publicar (misma key: el versionado hace su trabajo) → `apply` → responde v2
3. **rollback a v1 sin rebuild** → `apply` → responde v1

## Requisitos obligatorios

1. Backend remoto, key propia.
2. En `aws_lambda_function`: origen S3 (`s3_bucket` / `s3_key` / `s3_object_version`),
   sin rastro de `filename` ni de `data "archive_file"`. El zip lo haces tú en el script
   de build (el `zip` de toda la vida vale) y lo publicas con la CLI.
3. El `VersionId` del objeto entra a Terraform como **variable** (`-var` o `tfvars`).
   El rollback del paso 3 es literalmente `apply` con el VersionId viejo.
4. Responde en tu README, tras experimentar (no antes): **¿cómo sabe Terraform que el
   código cambió?** Publica v2 y ejecuta `plan` SIN cambiar la variable: ¿qué ve? ¿Y al
   cambiarla? Ahí está la diferencia entre la key, la versión y el hash — escríbela.
5. El pipeline manual queda en un script (`publish.sh` o target de pnpm): build → zip →
   `put-object` → imprimir el VersionId listo para pegar.

## Restricciones

- No toques el bucket del 02 desde este Terraform: aquí es **de solo lectura**
  (¿recuerdas qué herramienta de Terraform consulta sin gestionar?).
- Coste: ~0.

## Verificación — esto lo demuestra, esto no

```sh
# El ciclo completo, con las tres respuestas capturadas
aws lambda invoke --function-name practice-05-echo ... # → "version": "v1"
# ... publicar v2, apply ...
aws lambda invoke ... # → "version": "v2"
# ... apply con el VersionId de v1 ...
aws lambda invoke ... # → "version": "v1"   ← ESTA línea es el ejercicio

# Y la prueba de que no hiciste trampa: el rollback no recompiló nada
# (la marca de tiempo de tu dist/ no cambió entre el paso 2 y el 3)
```

Que la función responda no demuestra que el despliegue vino de S3: bórrale el zip local a
tu carpeta `build/` antes del último `apply` y que siga funcionando — eso sí lo demuestra.

Cierre: `terraform destroy` de lo de este ejercicio. El bucket del 02 sigue vivo (y ahora
guarda dos versiones de un artefacto de verdad).

## Antes de empezar

La lectura del zip en el despliegue la hace **quien ejecuta el `apply`** — tu usuario
`terraform`. Si tu ampliación del ejercicio 02 fue de verdad mínima, puede que aquí
descubras si fue *demasiado* mínima. El error, si llega, es de los buenos.

## Pistas

- `s3_object_version` es opcional en el provider. Todo este ejercicio es el argumento de
  por qué aquí no debería serlo — piénsalo con el paso 4 delante.
- Sin `archive_file` pierdes el hash gratis que te daba el data source. El provider tiene
  un argumento con «hash» en el nombre; decide si lo necesitas cuando ya fijas la versión
  del objeto, y que tu README lo diga con tus palabras.
- El `put-object` de la CLI te devuelve el VersionId en la respuesta. `aws s3 cp` no te
  lo enseña — elige bien el comando.
- Optimiza el zip como ya sabes: solo el bundle, sin sourcemap (aquella vez era el 75%
  del paquete).

## Dónde investigar

- Provider: [`aws_lambda_function`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/lambda_function.html.markdown)
  (sección de deployment package) ·
  [`aws_s3_bucket` (data)](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/d/s3_bucket.html.markdown)
- AWS: [desplegar zips desde S3](https://docs.aws.amazon.com/lambda/latest/dg/configuration-function-zip.html) ·
  [`put-object`](https://docs.aws.amazon.com/cli/latest/reference/s3api/put-object.html)
- [Ficha TypeScript en Lambda](../../reference/typescript-lambda.html) — artefacto vs bundle.

---

*¿Atascado de verdad (30+ min sin avanzar)? Pregúntame en el chat — orientar no es resolver.*
