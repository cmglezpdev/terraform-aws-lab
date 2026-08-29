# Rúbrica 05 — El artefacto desde S3

> **No leer antes de la revisión.**

## Checklist

- [ ] `s3_bucket`/`s3_key`/`s3_object_version` sin `filename` ni `archive_file`.
- [ ] Bucket referenciado con `data "aws_s3_bucket"` (o al menos el nombre por variable
      con justificación) — la restricción pedía la herramienta de solo lectura: data
      source. Si lo declaró como `resource`, tiene dos states gestionando el mismo bucket:
      error conceptual serio, conversación obligada sobre quién es el dueño de cada
      recurso.
- [ ] VersionId como variable; los tres applies del ciclo documentados con sus tres
      respuestas.
- [ ] El paso 4 respondido correctamente tras experimentar: con la key fija y sin
      `s3_object_version`, **Terraform no ve nada** al publicar v2 (ningún argumento
      cambió — el plan da No changes aunque el código sea otro). Con `s3_object_version`
      como variable, cambiar la variable cambia el plan. `source_code_hash` es la
      alternativa (hash del zip local); con versión fijada es redundante pero no dañino.
      Lo que busco: que diga con sus palabras que **Terraform compara configuración y
      state, no bytes en S3** — el plan no descarga tu zip.
- [ ] Script de publicación con `aws s3api put-object` (imprime VersionId). Si usó
      `aws s3 cp` y luego `list-object-versions` para pescar el id: funciona, pero que
      explique el rodeo.
- [ ] La prueba «borra build/ local y aplica» ejecutada o razonada.
- [ ] Zip solo con el bundle (sin sourcemap — `source_file`/zip del fichero, LR-0011).

## Trampas que espero

- **El plan que no ve el código nuevo** (paso 4): es LA trampa del ejercicio y es
  silenciosa — cuarta del hilo «fallo silencioso» en su variante Terraform. Quien
  publica v2 y ve «No changes» sin entender por qué, tiene la lección entera delante.
- Permisos: `CreateFunction`/`UpdateFunctionCode` leen el objeto con las credenciales de
  quien aplica → si su ampliación del 02 no incluyó `s3:GetObject` (y quizá
  `GetObjectVersion`) sobre `practice-*/*`, aquí revienta. Preparado en la rúbrica del
  02; quiero ver el diagnóstico, no el tropiezo.
- Referenciar el VersionId a mano dentro del `.tf` y editarlo cada vez: funciona, pero el
  requisito 3 pedía variable — el punto es que el rollback sea un valor, no un edit.
- Confundir rollback del **artefacto** con rollback del **state**.

## El listón

Que la frase «Terraform compara configuración con state, no con la realidad de los bytes»
salga de él, y que sepa cuándo elegir `filename` + hash (proyecto pequeño, un dev) frente
a S3 + versión (equipo/CI) — es una decisión con contexto, no una regla.

## Preguntas de la revisión

1. «¿Por qué el `plan` no detecta que publicaste v2?» (la respuesta del paso 4, oral y
   sin mirar).
2. «¿Qué te da `s3_object_version` que no te dé `source_code_hash`, y al revés?»
   (versión: rollback exacto y auditable, exige publicar antes; hash: detecta cambios
   del zip local sin variable, pero el rollback vuelve a ser recompilar).
3. «En CI, ¿quién debería poder `put-object` al bucket y quién solo `get`?» (separación
   publicador/desplegador — siembra del proyecto 07).
