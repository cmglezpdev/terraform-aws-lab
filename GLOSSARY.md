# Glosario: Terraform + AWS

El vocabulario canónico de este curso. Toda lección y todo README de proyecto usa estos
términos y no sus sinónimos. Un término entra aquí **cuando has demostrado que lo usas
bien**, no cuando te lo he explicado.

## Terraform

**Provider**:
Plugin que traduce HCL a llamadas de la API de un servicio concreto. `hashicorp/aws` es un
binario que Terraform descarga en `.terraform/`.
_Evitar_: driver, conector, plugin (a secas)

**Resource**:
Declaración de un objeto de infraestructura cuyo ciclo de vida completo gestiona Terraform:
lo crea, lo modifica y lo destruye.
_Evitar_: objeto, componente, servicio

**Data source**:
Consulta de solo lectura sobre algo que ya existe. No crea ni gestiona nada.
_Evitar_: lookup, query, fuente

**HCL**:
El lenguaje de configuración de Terraform. Declarativo: describes el estado final deseado,
no los pasos para llegar a él.
_Evitar_: sintaxis Terraform, código Terraform

**Plan**:
El diff calculado entre tu configuración y el state refrescado. Es un artefacto de revisión,
no un trámite previo al `apply`.
_Evitar_: preview, dry run, simulación

## Pendientes de promover

Términos introducidos en lecciones pero aún sin evidencia de uso correcto. Se mueven arriba
cuando aparezcan bien usados en una respuesta, un `plan` leído o un proyecto.

- **State** — introducido en [lección 01](./lessons/0001-el-primer-apply.html)
- **Drift** — introducido en [lección 01](./lessons/0001-el-primer-apply.html)
- **Dirección de recurso** — introducido en [lección 01](./lessons/0001-el-primer-apply.html); anatomía completa con clave de instancia en [lección 10](./lessons/0010-el-refactor-invisible.html)
- **Dependencia implícita** / **Grafo de dependencias** — introducidos en [lección 11](./lessons/0011-la-senal.html)
- **Bus de eventos** / **Regla** / **Patrón de eventos** / **Target** — introducidos en [lección 11](./lessons/0011-la-senal.html); ficha en [aws-eventbridge.html](./reference/aws-eventbridge.html)
- **Fan-out** — introducido en [lección 02](./lessons/0002-haz-que-la-alarma-suene.html)
- **Política de recurso** — introducido en [lección 02](./lessons/0002-haz-que-la-alarma-suene.html)
- **Confused deputy** — introducido en [lección 02](./lessons/0002-haz-que-la-alarma-suene.html)
- **Bloque `dynamic`** — introducido en [lección 02](./lessons/0002-haz-que-la-alarma-suene.html)
- **Backend** — introducido en [lección 03](./lessons/0003-saca-el-state-de-tu-portatil.html)
- **Lock** / **Lockfile** — introducido en [lección 03](./lessons/0003-saca-el-state-de-tu-portatil.html)
- **`lineage`** / **`serial`** — introducidos en [lección 03](./lessons/0003-saca-el-state-de-tu-portatil.html)
- **Objeto** / **Clave** / **Bucket** (S3) — introducidos en [lección 03](./lessons/0003-saca-el-state-de-tu-portatil.html)
- **Clase de almacenamiento** — introducida en [lección 03](./lessons/0003-saca-el-state-de-tu-portatil.html)
- **Módulo** / **Módulo raíz** — pendientes, proyecto 01
- **Principal** — introducido en [lección 04](./lessons/0004-deja-de-ser-root.html)
- **Política de identidad** — introducida en [lección 04](./lessons/0004-deja-de-ser-root.html)
- **Denegación implícita** / **explícita** — introducidas en [lección 04](./lessons/0004-deja-de-ser-root.html)
- **Rol** / **Política de confianza** — introducidos en [lección 04](./lessons/0004-deja-de-ser-root.html)
- **Permissions boundary** — introducido en [lección 04](./lessons/0004-deja-de-ser-root.html)
- **Credenciales temporales** — introducidas en [lección 04](./lessons/0004-deja-de-ser-root.html)
- **Rol de ejecución** — introducido en [lección 05](./lessons/0005-tu-codigo-en-aws.html)
- **Entorno de ejecución** / **Cold start** — introducidos en [lección 05](./lessons/0005-tu-codigo-en-aws.html)
- **GB-segundo** — introducido en [lección 05](./lessons/0005-tu-codigo-en-aws.html)
- **Handler** — introducido en [lección 05](./lessons/0005-tu-codigo-en-aws.html)
- **Invocación síncrona** / **asíncrona** / **event source mapping** — introducidas en [lección 05](./lessons/0005-tu-codigo-en-aws.html)
- **`local`** — introducido en [lección 05](./lessons/0005-tu-codigo-en-aws.html)
- **Dependencia explícita** (`depends_on`) — introducida en [lección 05](./lessons/0005-tu-codigo-en-aws.html)
- **Adaptador** / **Capa de dominio** / **Caso de uso** — introducidos en [lección 06](./lessons/0006-el-zip-no-es-tu-repositorio.html)
- **Tipo marcado** (*branded type*) — introducido en [lección 06](./lessons/0006-el-zip-no-es-tu-repositorio.html)
- **Parse, don't validate** — introducido en [lección 06](./lessons/0006-el-zip-no-es-tu-repositorio.html)
- **Tree shaking** — introducido en [lección 06](./lessons/0006-el-zip-no-es-tu-repositorio.html)
- **Sourcemap** — introducido en [lección 06](./lessons/0006-el-zip-no-es-tu-repositorio.html)
- **Clave de partición** — introducido en [lección 07](./lessons/0007-la-memoria-del-acortador.html)
- **Hot partition** — introducido en [lección 07](./lessons/0007-la-memoria-del-acortador.html)
- **Escritura condicional** (`ConditionExpression`) — introducido en [lección 07](./lessons/0007-la-memoria-del-acortador.html)
- **Upsert** — introducido en [lección 07](./lessons/0007-la-memoria-del-acortador.html)
- **Puerto y adaptador** — introducido en [lección 07](./lessons/0007-la-memoria-del-acortador.html)
- **Raíz de composición** — introducido en [lección 07](./lessons/0007-la-memoria-del-acortador.html)
- **Layer** (Lambda) — introducida en [lección 06](./lessons/0006-el-zip-no-es-tu-repositorio.html)
- **Ejecución duradera** / **Capacity provider** — introducidos en [lección 06](./lessons/0006-el-zip-no-es-tu-repositorio.html)
- **Route key** — introducido en [lección 08](./lessons/0008-la-puerta-publica.html)
- **Integración** (`AWS_PROXY`) — introducida en [lección 08](./lessons/0008-la-puerta-publica.html)
- **Stage** / **auto_deploy** — introducidos en [lección 08](./lessons/0008-la-puerta-publica.html)
- **Payload format 2.0** / **el sobre** — introducidos en [lección 08](./lessons/0008-la-puerta-publica.html)
- **Política basada en recursos** — introducida en [lección 02](./lessons/0002-haz-que-la-alarma-suene.html) como «política de recurso»; nombrada como tercera clase y leída con `get-policy` en [lección 08](./lessons/0008-la-puerta-publica.html)
- **Adaptador de protocolo** — introducido en [lección 08](./lessons/0008-la-puerta-publica.html)
- **Throttling** — introducido en [lección 08](./lessons/0008-la-puerta-publica.html)
- **`for_each`** / **clave de instancia** — introducidos en [lección 10](./lessons/0010-el-refactor-invisible.html)
- **Bloque `moved`** / **mudanza** — introducidos en [lección 10](./lessons/0010-el-refactor-invisible.html)
- **Refactor invisible** (plan a cero: solo mudanzas, nada que añadir ni destruir) — introducido en [lección 10](./lessons/0010-el-refactor-invisible.html)

## AWS

**Topic** (SNS):
Buzón de difusión al que se publica una vez y del que reciben copia todos los suscriptores.
No almacena: si nadie escucha, el mensaje se pierde.
_Evitar_: canal, cola, stream

**Fan-out**:
Patrón en el que un solo mensaje publicado se entrega simultáneamente a varios destinos
independientes, sin que el productor los conozca.
_Evitar_: broadcast, difusión múltiple

**Política de recurso**:
Permiso escrito en el propio recurso que dice quién puede actuar sobre él. Se opone a la
política de identidad, que se escribe en el rol o usuario que actúa.
_Evitar_: policy, permisos del recurso

**Alarma `ACTUAL` / `FORECASTED`** (Budgets):
`ACTUAL` compara con el gasto ya incurrido y avisa una sola vez por periodo. `FORECASTED`
compara con la proyección de AWS a fin de periodo y necesita ~5 semanas de historial.
_Evitar_: alarma real / alarma estimada

**Objeto** (S3):
Unos bytes con una **clave** de texto y unos metadatos. Se escribe entero y se lee entero.
Las barras de la clave no son carpetas: en S3 no hay carpetas.
_Evitar_: fichero, archivo, blob

**Clase de almacenamiento** (S3):
Atributo de cada objeto —no del bucket— que fija su precio por GB, su latencia de acceso y su
duración mínima facturable. Se cambia sola con reglas de ciclo de vida.
_Evitar_: tier, nivel, tipo de bucket

**Principal** (IAM):
Quién hace la petición: un usuario IAM, una sesión de rol, un servicio de AWS o el root. No
es «el usuario»: una Lambda también es un principal.
_Evitar_: actor, sujeto, identidad (a secas)

**Política de identidad** (IAM):
Permiso escrito en el usuario, grupo o rol que actúa. Es la contraria de la **política de
recurso**. Dentro de una cuenta las dos se suman: basta con que una conceda.
_Evitar_: permisos del usuario, IAM policy

**Denegación implícita** (IAM):
El estado por defecto de toda petición: nadie la ha permitido. Se contrapone a la
**denegación explícita**, que es un `Deny` escrito y que gana sobre cualquier `Allow`.
_Evitar_: denegado por defecto, sin permisos

**Rol** (IAM):
Identidad sin credenciales propias que otros asumen; STS presta credenciales temporales por
un máximo de 12 horas. Lleva siempre una **política de confianza** que dice quién puede
asumirlo. Un rol sin política de confianza no sirve para nada.
_Evitar_: cuenta de servicio, perfil, usuario técnico

**Permissions boundary** (IAM):
Techo máximo de permisos de un usuario o rol. **No concede nada**: el permiso efectivo es la
intersección con las políticas de identidad. Igual que los SCP, solo resta.
_Evitar_: límite de permisos, política máxima

Referencias completas por servicio en [`reference/`](./reference/README.md).

## Ambigüedades resueltas en este curso

- **«Bloqueo del state»** siempre significa el bloqueo nativo de S3 (`use_lockfile = true`),
  que en la práctica es un objeto `<key>.tflock` en el mismo bucket. El bloqueo mediante una
  tabla de DynamoDB está deprecado desde Terraform 1.11.0 y en este curso no se usa, aunque lo
  veas en casi todo el material de internet.
- **«Backend»** es la respuesta a *dónde vive el state y quién decide quién lo escribe*. No
  confundir con el backend de una aplicación.
- **«Entorno»** significa `dev` o `prod` como despliegues separados con state propio, no un
  `terraform workspace`. Cuando hablemos de workspaces lo diremos con esa palabra.
- **«Módulo»** sin apellido significa un módulo hijo reutilizable. Al directorio donde
  ejecutas `terraform apply` lo llamamos siempre **módulo raíz**.
- **«Root»** significa siempre el usuario raíz de la cuenta AWS, nunca el usuario `root` de
  un sistema Unix ni el módulo raíz de Terraform. Cuando hablemos del segundo diremos
  **módulo raíz**, con las dos palabras.
- **«Rol de ejecución»** es siempre el rol que asume el servicio Lambda para ejecutar tu
  función. No confundir con el rol que asume una persona ni con un *instance profile*. La
  identidad que ejecuta `terraform apply` la llamamos siempre **usuario `terraform`**.
- **«Build»** es transformar TypeScript en el `.js` empaquetado, y ocurre siempre **fuera**
  de Terraform. Cuando digamos «desplegar» nos referimos solo al `apply`.
- **«Artefacto»** es el `.zip` que Lambda ejecuta, no tu repositorio. La diferencia importa:
  el repositorio tiene tests, sourcemaps y `node_modules`; el artefacto tiene un fichero.
- **«Bundle»** es el `dist/index.mjs` que produce esbuild, con las dependencias dentro. No
  confundir con el `.zip` (el artefacto), que es lo que sube a AWS.
- **«Dominio»** significa siempre la capa de reglas de negocio del código de una Lambda, nunca
  un nombre DNS. Para lo segundo diremos **dominio DNS**, con las dos palabras.
- **«Test»** sin apellido significa test unitario ejecutado con `node --test`, sin AWS. Probar
  contra AWS real lo llamamos siempre **verificar** o **test de integración**.
- **«Perfil»** es un perfil de la AWS CLI en `~/.aws/config`. Desde la lección 04,
  `personal` es la identidad de trabajo (usuario IAM `terraform`) y `personal-root` es la
  vía de escape. No confundir con *instance profile*, que es otra cosa de IAM.
