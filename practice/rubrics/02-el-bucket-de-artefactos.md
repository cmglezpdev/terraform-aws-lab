# Rúbrica 02 — El bucket de artefactos

> **No leer antes de la revisión.**

## Checklist

- [ ] Ampliación de `terraform-course` con alcance defendible. Bien:
      statements sobre `arn:aws:s3:::practice-*` **y** `arn:aws:s3:::practice-*/*`
      (bucket y objetos, separados o justificados). Mal: `s3:*` sobre `*`. El diff del
      proyecto 00 debe existir y estar aplicado.
- [ ] Versionado con `aws_s3_bucket_versioning` (recurso propio, no el argumento
      deprecado embebido en `aws_s3_bucket`).
- [ ] `aws_s3_bucket_public_access_block` con las cuatro banderas en `true`.
- [ ] Política de recurso: `Deny` + `Principal: "*"` + condición
      `aws:SecureTransport = false`, sobre bucket **y** objetos (los dos ARNs — es la
      misma trampa bucket/objeto de la lección 04, tercera aparición).
- [ ] Dos `VersionId` reales capturados, artefacto subido por CLI, jamás por Terraform.
- [ ] La excepción al `destroy` está escrita en su README con motivo y coste.
- [ ] Si usó `random_id`/`bucket_prefix` para el sufijo: pídele que explique qué provider
      lo da y qué crea en AWS (nada — buen momento para «no todo recurso es remoto»).

## Trampas que espero

- **La denegación sin los dos ARNs**: `Resource` solo con `/*` deja fuera operaciones de
  bucket (`ListBucket` sin TLS pasaría). Es el detalle que separa copiar de entender.
- **`Deny` explícito gana a todo**: si se pasa de listo con la condición y se deniega a sí
  mismo (p. ej. `aws:SecureTransport` mal escrito), el bucket se vuelve inmanejable y hay
  que borrar la política desde root. Si le pasó y lo arregló: experiencia valiosa, que la
  cuente.
- Olvidar que su política de usuario también necesita `GetObject` sobre los objetos del
  bucket para el ejercicio 05 (CreateFunction lee el zip con las credenciales de quien
  aplica). No lo aviso: si su alcance del punto 1 ya lo cubre, perfecto; si no, el
  ejercicio 05 se lo enseñará con un error.
- El conflicto public-access-block ↔ bucket-policy en aplies concurrentes (el provider
  documenta el orden); si le salió un error intermitente, ¿lo resolvió con dependencia o
  reintentando a ciegas?

## El listón

Que la política del usuario ampliada sea **enseñable**: cada statement con una frase de
defensa. Y que el README distinga lo demostrado (versionado, banderas) de lo afirmado
(TLS) — LR-0003 aplicado sin que yo lo pida.

## Preguntas de la revisión

1. «¿Por qué versionado y bloqueo público son recursos separados y no argumentos del
   bucket?» (v4 del provider: ciclo de vida independiente, equipos distintos).
2. «¿Qué protege el public access block que tu política de recurso no protege ya?»
   (el bloqueo es un cinturón sobre errores *futuros* — ACLs, políticas que alguien
   añada; la política actual solo dice lo que dice hoy).
3. «Tu bucket de state ya versionaba. ¿Qué recuperas con un `VersionId` viejo en cada
   caso?» (state = post-mortem lección 03 pendiente; artefactos = rollback, ejercicio 05).
