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
- **Dirección de recurso** — introducido en [lección 01](./lessons/0001-el-primer-apply.html)
- **Dependencia implícita** — pendiente, proyecto 01
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
