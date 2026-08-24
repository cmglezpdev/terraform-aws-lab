# `-migrate-state` copia, y él borró el origen antes de pedir la copia

Durante la lección 03 (2026-08-23, ~22:40) el usuario migró el state con la `key` equivocada
(`terraform.tfstate` en lugar de `00-foundations/terraform.tfstate`). Al darse cuenta,
**borró el objeto de S3 a mano y luego corrigió la `key` y reintentó la migración**. La
migración no tenía nada que copiar. Al quitar el backend para volver a local, Terraform
escribió un `terraform.tfstate` vacío y el siguiente `plan` propuso crear los 9 recursos
desde cero.

Desenlace: **no se perdió nada.** Al reponer `backend.tf` con la key correcta, la migración
partió del `.backup` local y dejó el state completo en
`00-foundations/terraform.tfstate`. `terraform plan` devolvió `No changes` con los 9 recursos
y los mismos IDs reales.

## Lo que hay que enseñarle explícitamente a partir de ahora

**La distinción `-migrate-state` / `-reconfigure` no estaba en la lección 03, y hace falta.**

- `-migrate-state` = copia el state de donde estaba a donde dice la configuración nueva.
- `-reconfigure` = descarta el backend anterior y usa el nuevo tal cual, sin copiar nada.

Mover un state de una `key` a otra tiene dos caminos correctos, y en ambos **el borrado del
origen va al final**: migrar y luego borrar, o mover el objeto con `aws s3 mv` y después
`-reconfigure`. Ya estaba anotado en NOTES como idea suelta de 5 minutos; ha resultado ser
material de primera necesidad.

**`terraform.tfstate.backup` no es un sistema de copias.** Guarda solo la escritura
inmediatamente anterior, se machaca en cada escritura, y **desaparece al pasar a backend
remoto**. El usuario asumió que era la red de seguridad principal. La red real es el
versionado de S3, que es justo lo que la lección 03 le hizo activar y que él no usó.

**Cada migración acuñó un `lineage` nuevo** (local `9d24…`, S3 path malo `668e…`, S3 path
bueno `684d…`). Consecuencia práctica que hay que decirle: su `.backup` local ya no es
intercambiable con el state de S3; un `state push` se negaría por `lineage` distinto.

## Por qué esto es una buena noticia

Es el **post-mortem provocado que estaba planificado para más adelante**, ocurrido solo que
de verdad y por su cuenta. Ya tiene la experiencia vivida de: state vacío, `plan` que quiere
crearlo todo, y recuperación. La lección futura de corrupción de state debe **partir de este
incidente** en lugar de inventarse uno.

Y confirma la decisión de la lección 03 de activar el versionado antes de migrar: si no lo
hubiera tenido puesto, su borrado manual del objeto habría sido definitivo.

## Reflejo a mantener

Ejecutó `plan` y preguntó en vez de ejecutar `apply`. Con el state vacío, un `apply` habría
intentado recrear los 9 recursos: `BucketAlreadyOwnedByYou`, presupuesto duplicado, y un topic
SNS adoptado en silencio. Es la misma prudencia de [LR-0003](./0003-el-apply-no-es-la-prueba.md)
y hay que reforzarla nombrándola.

## Detalle menor resuelto

Eligió `tf-state-learning-course-terraform` en vez de `tf-state-<id-cuenta>`. Sin querer,
eso deja el ID de cuenta fuera de `backend.tf`. La decisión pendiente de
[LR-0005](./0005-una-leccion-un-tema.md) sigue viva solo para `MISSION.md` y
`reference/terraform-cli.html`.
