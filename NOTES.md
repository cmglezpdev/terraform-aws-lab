# Notas de trabajo

## Preferencias del usuario

- **Idioma**: español. Términos técnicos e identificadores de código en inglés.
- **Odia los ejercicios de juguete.** "Crea un bucket S3" no le sirve: no ve el caso de uso.
  Todo debe estar dentro de un proyecto con una razón de existir.
- **TypeScript siempre.** Nada de JS plano, Java, Go ni Python. Bundle con `esbuild`.
- Cree que Terraform es "bastante sencillo" y que la dificultad está en configurar AWS.
  Parcialmente cierto — pero state, módulos y el ciclo `plan` van a sorprenderle.
  No darle la razón por comodidad: enseñar los sitios donde Terraform sí es difícil.
- Quiere entender **por qué** cada pieza está donde está (System Design), no solo el cómo.

> Este fichero es público. Los identificadores de cuenta que aparezcan aquí y en el resto
> del repositorio son **marcadores de posición**, no valores reales.

## Entorno (verificado 2026-08-23)

- Terraform `v1.15.8` (Homebrew), AWS CLI `2.36.5`, Node `v24.18.0`, npm `11.16.0`.
- `~/.aws/config` tiene varios perfiles. El del curso es **`personal`**; hay otro de trabajo
  que no se toca. De ahí que toda lección empiece con `aws sts get-caller-identity`: nunca
  damos por hecho en qué cuenta estamos.
- No hay sesión activa por defecto. Usa `aws login` (config con `login_session`, no
  `sso_start_url`).
- **Pendiente crítico**: el perfil del curso usa todavía las credenciales iniciales de la
  cuenta. Crear una identidad IAM dedicada a Terraform es el objetivo de la lección 04.

## Decisiones de enseñanza

- **Cada servicio AWS lleva su propio bloque explicativo** (petición explícita, LR-0004).
  Formato: `.anatomy` embebido en la lección (preguntas 1, 3 y 5) + referencia completa en
  `reference/aws-<servicio>.html`. Generado con el skill `aws-service-explainer`.
- **Nunca escribir precios ni límites de memoria.** Verificar contra la doc de AWS o, mejor,
  contra la Price List API pública:
  `https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/<Servicio>/current/<región>/index.json`
  (sin credenciales, devuelve JSON con las tarifas reales). Fecha de verificación en el doc.
- **Toda infra desplegada lleva un paso de verificación explícito** y una frase de «esto lo
  demuestra, esto no» (LR-0003). El usuario detectó por su cuenta que la alarma no estaba
  probada; ese reflejo hay que alimentarlo.
- La web del Terraform Registry es una SPA: `WebFetch` devuelve vacío. Usar siempre
  `https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/<recurso>.html.markdown`.

- Enseñar el backend S3 con `use_lockfile = true`, NO con DynamoDB (deprecado). Casi todo
  el material que encuentre por internet usará DynamoDB — avisarle explícitamente.
- Regla de coste: los proyectos 04 y 06 se aplican con cronómetro. El resto es pago por uso.
- Cada lección termina con un `destroy` verificado. Nunca dejar infra levantada "para mañana"
  sin decirlo explícitamente.

- **Una lección, un tema** (LR-0005). Si al diseñarla no cabe en 40 min, se parte, y la
  lección dice al pie que se ha partido y por qué. No dejar que el usuario piense que se me
  olvidó lo que anuncié.
- **Resuelto (2026-08-24)**: todos los identificadores de cuenta del repositorio son
  marcadores de posición. El bucket de state se llama `tf-state-learning-course-terraform`,
  sin el ID dentro, así que `backend.tf` no expone nada. Si en el futuro un ejemplo necesita
  un ID, usar `999999999999`. La alternativa de *partial configuration* con
  `-backend-config=backend.hcl` sigue reservada para el proyecto 07.

## Ideas para futuras lecciones

- El `plan` como herramienta de lectura: enseñarle a leer un diff de 200 líneas.
- Quitar el presupuesto canario de 1 USD cuando la cuenta cumpla ~5 semanas y `FORECASTED`
  despierte. Anotado hacia finales de septiembre de 2026.
- `terraform state mv` / `import` — lo que separa a quien sabe de quien copia.
- Por qué `count` rompe cosas al borrar el elemento del medio, y `for_each` no.
- Un post-mortem provocado: corromper el state a propósito y recuperarlo. **Prometido
  explícitamente en la lección 03** («la vamos a hacer provocando el desastre a propósito»).
  Con el versionado de S3 ya activo, se hace recuperando un `VersionId` anterior.
- Reglas de ciclo de vida de S3 — la ficha `reference/aws-s3.html` las deja fuera a propósito
  y ofrece explicarlas si las pide. Encajan de forma natural en el proyecto 02.
- `terraform init -reconfigure` frente a `-migrate-state`: **ya se equivocó** (LR-0006).
  Meterlo en la próxima lección, no esperar.
