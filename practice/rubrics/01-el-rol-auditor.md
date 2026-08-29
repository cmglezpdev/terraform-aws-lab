# Rúbrica 01 — El rol auditor

> **No leer antes de la revisión.**

## Checklist

- [ ] Backend S3 con key que respeta el patrón `*/terraform.tfstate` de la política
      `StateObject`. Si usó otra key y se comió el 403, ¿lo diagnosticó solo y lo cuenta?
      (vale doble).
- [ ] Política de confianza: `principals` con `type = "AWS"` e `identifiers` = ARN exacto
      del usuario, obtenido de `data.aws_caller_identity` (el ARN del *user*, no el
      `account_id` a pelo). Cero ARNs escritos a mano.
- [ ] Política de identidad: solo control plane. Esperable:
      `dynamodb:DescribeTable`, `dynamodb:ListTables`, `lambda:GetFunction*`,
      `lambda:ListFunctions`. Sin `Get*` genérico que arrastre data plane
      (`lambda:GetFunction` sí incluye la URL del código — si lo detectó y lo comenta,
      sobresaliente; no lo penalizo si no).
- [ ] Separación de statements según recurso: `ListTables`/`ListFunctions` **no admiten
      recurso concreto** → statement propio con `resources = ["*"]`; `DescribeTable` sí
      admite ARN. Si todo va en un statement con `*`, es el punto débil a discutir.
- [ ] Las tres patas de la verificación hechas, con el `AccessDenied` del paso 3 guardado.
- [ ] `destroy` verificado.

## Trampas que espero

- **La key del state**: es la trampa silenciosa colocada a propósito. El 403 de S3 al
  `init`/`apply` no menciona la política; hay que releer `iam.tf` del proyecto 00.
- **¿Hace falta `sts:AssumeRole` en la política del usuario?** Mismo­-cuenta con principal
  nombrado por ARN: la confianza basta (es la excepción documentada de las políticas
  basadas en recursos). Le pedí probarlo antes de leerlo — lo que evalúo es el orden:
  experimento → doc, no la respuesta memorizada. Si le falló por las credenciales
  temporales de `aws login`, el diagnóstico del error vale tanto como el éxito.
- Confundir las dos políticas (LR-0010): si `sts:AssumeRole` aparece en la política de
  *identidad del rol*, no entendió cuál mira afuera.
- Poner `:root` de principal «porque lo vi en internet» — prohibido explícitamente.

## El listón

Least privilege real y **argumentado**: cada statement debe poder defenderse con una
frase. La pregunta de fondo es si distingue control plane de data plane con esas palabras.

## Preguntas de la revisión

1. «¿Por qué `ListTables` está en un statement aparte con `*`? ¿Qué pasaría si lo
   restringes al ARN de `links`?» (debe saber que la acción no admite resource-level).
2. «Si mañana esto lo asume una herramienta externa desde *otra cuenta*, ¿qué cambia?»
   (busco: principal de otra cuenta + **las dos políticas hacen falta** + `external_id` /
   confused deputy, aunque sea de oídas — enlaza con el proyecto 07).
3. «¿Qué diferencia hay entre este rol y un permissions boundary?» (uno concede, el otro
   solo recorta — lección 04).
