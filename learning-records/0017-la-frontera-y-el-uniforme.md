# La frontera tiene nombre y el uniforme se juzga entero

2026-08-30, ejercicio 01 de `practice/` (el rol auditor) — primera revisión contra rúbrica
oculta de la sección. **Aprobado.** La trampa de la key del backend no saltó: la eligió
bien a la primera. Por el camino, dos bugs instructivos en la política de confianza
(`type = "User"` y un ARN interpolado dentro de otro ARN) que dejaron una lección previa a
las cuatro grandes: **el provider no valida la semántica del documento JSON; la valida AWS
en el apply**. HCL válido ≠ política válida.

## Las cuatro lecciones que se lleva

1. **Control plane / data plane** como criterio para escribir políticas, con esas palabras.
   Y el matiz sobresaliente (dado, no descubierto): `lambda:GetFunction` devuelve
   `Code.Location`, una URL prefirmada que descarga el .zip — el «auditor que no lee nada»
   puede bajarse el código. `GetFunctionConfiguration` es la variante ciega — y tras la
   revisión cambió su política a esa variante por decisión propia, sin que se le pidiera.
2. **«No admite resource-level permissions» ≠ «no hace falta ARN»**. Ponerle un ARN a
   `ListTables` no acota: mata el statement entero en silencio y el síntoma es un
   `AccessDenied` sin pista. De ahí la separación en statements. Acertó el reparto; el
   mecanismo hubo que afilarlo.
3. **Identidad + recurso se suman**: su usuario no necesitó `sts:AssumeRole` porque la
   política de confianza es la política *de recurso* del rol y concedió ella. Hizo el
   experimento antes de leer la doc (el orden que se evalúa). Corregido el sujeto de su
   frase: el rol no «tiene» el permiso — se lo otorga al usuario. Con `:root` habría sido
   delegación y sí haría falta la política de identidad.
4. **Una decisión defendida gana a la letra de la rúbrica.** La rúbrica pedía cero ARNs a
   mano (`current.arn`); él construyó `account_id` + nombre fijo y lo argumentó:
   `current.arn` significa «quien ejecute», y la trust policy debe decir «el usuario
   terraform» aunque aplique root. Se le retiró el hallazgo. Queda como precedente del
   listón: cada statement, defendible con una frase. (Síntesis ofrecida:
   `data "aws_iam_user"` — nombre en un solo sitio, validado en plan.)

## Señales para el proyecto 07

Los huecos que salieron en las preguntas, por orden de urgencia cuando llegue cross-account:
asumir rol **entre cuentas** exige las dos políticas (falló la pregunta: creyó que la
confianza viajaba sola); `external_id` / confused deputy solo de oídas; **permissions
boundary** desconocido (enseñado con sombrero-vs-tapa); Organizations, federación e
Identity Center sin contexto aún — curso mono-cuenta, no adelantar.

## Qué se escribió durante el ejercicio

- `reference/aws-iam.html` — sección nueva «Dónde se buscan las acciones» (Service
  Authorization Reference, los cinco access levels, la trampa del Resource types vacío).
- GLOSSARY: «Service Authorization Reference» y «Access level» en pendientes de promover.
