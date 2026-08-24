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
  `sso_start_url`). Credenciales temporales, refresco automático, 12 h de tope, caché en
  `~/.aws/login/cache`, se tiran con `aws logout`.
- **Resuelto en la lección 04 (2026-08-24)**: `personal` = usuario IAM `terraform` (identidad
  de trabajo), `personal-root` = root (vía de escape). El usuario **no tiene claves de
  acceso**: entra por `aws login`. Ver [LR-0007](./learning-records/0007-usuario-iam-sin-claves.md).
- **`aws login` con un usuario IAM exige la política gestionada
  `arn:aws:iam::aws:policy/SignInLocalDevelopmentAccess`.** Root no la necesita. Está
  documentada solo en la guía de la CLI, no en la de IAM.

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

- **El truco de `terraform validate` con un valor inventado** es su autocompletado real para
  los argumentos de lista cerrada: el provider enumera los valores válidos en el error, sin
  credenciales y sin tocar AWS. Verificado el 2026-08-24 con su provider 6.61.0. Está en
  `reference/terraform-cli.html`. Usarlo siempre que pregunte «¿y qué valores acepta esto?»
  en vez de darle la respuesta directamente (LR-0009).
- **El informe de credenciales** (`aws iam generate-credential-report` +
  `get-credential-report`) es la forma no negociable de verificar el estado de root: MFA
  activo y claves de acceso inactivas. Estrenado en la lección 04. Reutilizarlo cada vez que
  se hable de seguridad de la cuenta, en vez de pedirle que mire la consola.
- **Los cuatro niveles del arranque privilegiado** (tabla al final de la lección 04) son ya
  vocabulario compartido: 0 módulo raíz que crea a su sucesor, 1 bootstrap aparte, 2 rol
  asumible, 3 organización con OIDC. Referirse a ellos por número. El proyecto 07 se presenta
  como «subir del 0 al 3», no como material nuevo (LR-0008).
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
- **`sts:AssumeRole` y los roles a fondo**, ofrecido al pie de `reference/aws-iam.html`. Es
  lo que más se pregunta en entrevistas y hoy solo se ha nombrado. Encaja de forma natural
  antes del proyecto 07, o antes si lo pide.
- **MFA para el usuario `terraform`**: no se puede crear desde Terraform (hace falta escanear
  un QR). Queda pendiente y la lección 04 lo dice en «esto no lo demuestra».
- **Activar el acceso de IAM a la consola de facturación** (tarea de root). Sin ello el
  usuario `terraform` no puede ver el presupuesto que él mismo gestiona. Ofrecido en la
  lección 04, no forzado.
- Por qué `count` rompe cosas al borrar el elemento del medio, y `for_each` no.
- Un post-mortem provocado: corromper el state a propósito y recuperarlo. **Prometido
  explícitamente en la lección 03** («la vamos a hacer provocando el desastre a propósito»).
  Con el versionado de S3 ya activo, se hace recuperando un `VersionId` anterior.
- Reglas de ciclo de vida de S3 — la ficha `reference/aws-s3.html` las deja fuera a propósito
  y ofrece explicarlas si las pide. Encajan de forma natural en el proyecto 02.
- ~~`terraform init -reconfigure` frente a `-migrate-state`~~ — **hecho** en la lección 04,
  como tercer bloque de recuperación (LR-0006).
