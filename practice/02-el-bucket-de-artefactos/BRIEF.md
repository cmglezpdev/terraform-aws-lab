# Ejercicio 02 — El bucket de artefactos

> Dificultad ●○○ · ~45-60 min · Servicios: S3, IAM
> Prerequisito: [lección 04](../../lessons/0004-deja-de-ser-root.html)

## Contexto

Tu repo es público y tus artefactos (`.zip` de Lambda) no van en git — eso quedó claro en
la lección 06. Pero entonces, ¿dónde viven? Hoy: en tu portátil, en `build/`. El día que
haya CI (proyecto 07), o un segundo desarrollador, eso no vale. La respuesta estándar es
un **bucket de artefactos**: versionado, privado a cal y canto, y con los permisos justos.

Este bucket **se queda vivo** al terminar: el ejercicio 05 lo usa como origen de despliegue.
Es la primera pieza de práctica que construyes para reutilizar, no para tirar.

## Lo que vas a construir

Un bucket `practice-02-artifacts-<sufijo>` (el nombre es global en todo AWS: elige sufijo)
que:

- tiene **versionado activado**,
- tiene **bloqueado todo acceso público** — con el recurso explícito del provider que
  existe para eso, no confiando en el default,
- **rechaza cualquier petición sin TLS** mediante su política de recurso,
- y recibe tu primer artefacto real: el zip del acortador, subido **por la CLI** (el build
  y el transporte del artefacto nunca entran en Terraform — mismo principio que el
  build).

## Requisitos obligatorios

1. Backend remoto, key propia (ya sabes qué patrón exige tu política).
2. **Antes de nada**: tu política `terraform-course` solo permite `s3:*` sobre el bucket
   de state. Amplíala en `projects/00-foundations/` para poder gestionar buckets de
   práctica — pero **con el alcance mínimo que se te ocurra defender**, no con `s3:*`
   sobre `*`. Ese diff es parte del entregable.
3. Versionado y bloqueo público: cada uno con su recurso propio del provider (son
   recursos separados del `aws_s3_bucket` desde el provider v4 — si no lo sabías, ahora
   tienes el porqué que investigar).
4. La política de recurso con la denegación de tráfico sin TLS usa la condición
   estándar de AWS para esto (existe una condición global concreta; encuéntrala).
5. Sube el mismo zip **dos veces** (recompila entre medias para que cambie) y captura los
   dos `VersionId`.

## Restricciones

- Sin Lambda todavía: el consumo del artefacto es el ejercicio 05.
- Coste: ~0 (unos KB almacenados; el versionado duplica objetos, no céntimos a tu escala).

## Verificación — esto lo demuestra, esto no

```sh
# El versionado existe y guarda historia (dos VersionId distintos para la misma key)
aws s3api list-object-versions --bucket <bucket> --prefix create-link/ --profile personal

# El bloqueo público está activo (las cuatro banderas en true)
aws s3api get-public-access-block --bucket <bucket> --profile personal

# La política de recurso está puesta y dice lo que crees que dice
aws s3api get-bucket-policy --bucket <bucket> --profile personal
```

El `apply` limpio **no** demuestra que el bucket rechaza HTTP: eso lo afirma la política,
y hoy te vale leerla (probar TLS-off desde la CLI no es trivial — dilo en tu README como
«esto no lo he demostrado, lo afirma la política»; esa honestidad es un requisito, no una
debilidad).

Cierre: este ejercicio **no se destruye** — anótalo en tu README con el motivo y el coste
en reposo (~0). Es la primera excepción consciente a la regla del curso, y tiene que estar
escrita.

## Pistas

- El sufijo del nombre: hay un recurso del provider pensado para generar sufijos únicos
  sin inventártelos tú. De paso aprendes que no todos los recursos crean cosas en AWS.
- «Alcance mínimo» en la política del usuario tiene dos ejes: qué acciones y qué ARNs.
  Recuerda la trampa de la lección 04: el ARN del bucket y el de sus objetos no son el
  mismo recurso.
- El orden de tus recursos no importa; sus dependencias sí. ¿Puede aplicarse la política
  de recurso antes que el bloqueo público? Mira qué dice el provider sobre conflictos
  entre esos dos recursos.

## Dónde investigar

- [Ficha S3 del curso](../../reference/aws-s3.html) — objeto, clave, versionado.
- Provider: [`aws_s3_bucket_versioning`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/s3_bucket_versioning.html.markdown) ·
  [`aws_s3_bucket_public_access_block`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/s3_bucket_public_access_block.html.markdown) ·
  [`aws_s3_bucket_policy`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/s3_bucket_policy.html.markdown)
- AWS: [bloqueo de acceso público](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html) ·
  [condiciones globales de IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html)

---

*¿Atascado de verdad (30+ min sin avanzar)? Pregúntame en el chat — orientar no es resolver.*
