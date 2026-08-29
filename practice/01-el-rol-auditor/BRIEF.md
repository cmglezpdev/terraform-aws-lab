# Ejercicio 01 — El rol auditor

> Dificultad ●○○ · ~45 min · Servicios: IAM, STS
> Prerequisito: [lección 04](../../lessons/0004-deja-de-ser-root.html)

## Contexto

En tu equipo entra una herramienta de auditoría (o un compañero de otro equipo, da igual:
un principal que no eres tú) que necesita **ver** qué hay desplegado en la cuenta — qué
tablas existen, qué funciones, con qué configuración — pero que **jamás** debe poder leer
datos ni cambiar nada. La respuesta de entrevista «le creo un usuario y le doy ReadOnly»
es exactamente la que este ejercicio te quita: aquí no se crea ningún usuario. Se crea un
**rol**, y quien lo necesite se lo pone.

Hasta ahora todas tus políticas de confianza tenían como principal un servicio
(`lambda.amazonaws.com`, `budgets.amazonaws.com`). Hoy el principal eres tú: el usuario
`terraform` asumiendo un rol. Las tres preguntas de siempre, otro principal.

## Lo que vas a construir

Un rol `practice-01-auditor` que:

- solo puede asumir el usuario `terraform` (nadie más: ni la cuenta entera, ni root),
- puede **listar y describir** tablas de DynamoDB y funciones Lambda de la cuenta,
- **no** puede leer ítems, ni escribir, ni borrar nada.

Y la demostración completa de las tres cosas desde la CLI.

## Requisitos obligatorios

1. Backend remoto en el bucket del curso, con su propia key.
2. La política de confianza nombra al usuario `terraform` **por ARN exacto**. Prohibido
   poner la cuenta entera (`:root`) como principal.
3. La política de identidad del rol se escribe con `data "aws_iam_policy_document"`, como
   en el proyecto 00, y concede **solo** acciones de lectura de metadatos. Nada de
   políticas gestionadas de AWS (`ReadOnlyAccess` está prohibida — el punto es escribirla tú).
4. El ARN del usuario no se escribe a mano: hay un data source que te da la identidad de
   la llamada actual. Encuéntralo.
5. Un `output` con el comando `aws sts assume-role` listo para copiar y pegar.

## Restricciones

- Sin Lambda, sin código: este ejercicio es IAM puro.
- Coste: 0. IAM y STS no facturan.

## Verificación — esto lo demuestra, esto no

El `apply` limpio no demuestra nada: IAM acepta encantado políticas que no funcionan. La
prueba tiene tres patas, y **las tres son obligatorias**:

```sh
# 1. Puedes ponerte el uniforme
aws sts assume-role --role-arn <arn> --role-session-name audit --profile personal

# (exporta las tres variables de entorno que te devuelve y sigue con ellas)

# 2. La tarjeta abre las puertas de lectura
aws dynamodb describe-table --table-name links
aws lambda get-function --function-name create_link

# 3. Y NO abre las demás — el AccessDenied es el resultado esperado
aws dynamodb get-item --table-name links --key '{"code":{"S":"algo"}}'
aws dynamodb delete-table --table-name links
```

Si el paso 3 no falla, el ejercicio no está terminado — está mal. Guarda las salidas: en
la revisión te pediré el `AccessDenied` literal.

Cierre: `terraform destroy`, y comprueba con `aws iam list-roles` (perfil normal) que el
rol ya no existe.

## Antes de empezar

Tu política `terraform-course` ya tiene `iam:*`. Lo que no sabes aún es si asumir un rol
exige algo más que la política de confianza. **No lo busques primero: pruébalo**, y deja
que el error (si lo hay) te lo enseñe. Luego contrasta con la doc lo que hayas visto.

## Pistas

- Las dos políticas del rol no se parecen en nada aunque compartan palabra. Antes de
  escribir, decide cuál mira afuera y cuál mira adentro — si las mezclas, el error que da
  AWS no te va a ayudar.
- No todas las acciones de IAM aceptan un ARN concreto en `resources`. Cuando un
  `AccessDenied` no cuadre con lo que crees haber concedido, pregúntate si esa acción
  admite recurso o exige `*`.
- Describir una tabla y leer un ítem se parecen mucho en la CLI y nada en IAM. La frontera
  tiene nombre; te será útil saberlo para la revisión.
- El error de STS distingue quién te niega. Léelo entero antes de tocar nada.

## Dónde investigar

- [Ficha IAM del curso](../../reference/aws-iam.html) — las tres preguntas y el uniforme.
- Provider: [`aws_iam_role`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/iam_role.html.markdown) ·
  [`aws_iam_role_policy`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/iam_role_policy.html.markdown) ·
  [`caller_identity` (data)](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/d/caller_identity.html.markdown)
- AWS: [API AssumeRole](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) ·
  [acciones y recursos de DynamoDB en IAM](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazondynamodb.html)

---

*¿Atascado de verdad (30+ min sin avanzar)? Pregúntame en el chat — orientar no es resolver.*
