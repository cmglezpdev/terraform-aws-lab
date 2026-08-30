# El refactor invisible: la dirección es la identidad, y el plan es el detector de mentiras

2026-08-29, lección 10 — cierra el proyecto 01. Los gemelos `create-link.tf`/`get-link.tf`
se funden con `for_each` sobre `local.functions` y dieciséis bloques `moved`, con la vara
enseñada desde el deck: **AWS no debe enterarse** (0 a añadir, 0 a destruir). Dos ideas
quedan como vocabulario: **la dirección es la identidad** (el plan empareja direcciones,
nunca «configuraciones equivalentes») y **el refactor de IaC se revisa leyendo el plan, no
el código**.

## Los accidentes reales — encontrados leyendo su código, servidos como ejercicio

La predicción de la lección 09 («los gemelos van a divergir») ya se había cumplido cuando se
escribió la 10, y por partida doble, en su propia transcripción:

- `build/create_link.zip` (guion bajo, herencia de la lección 05) contra
  `build/get-link.zip` (guion — la lección 09 decía `get_link.zip`; él escribió guion).
- `integration_uri` de `get_link` con `.arn` donde su gemelo usa `.invoke_arn` (la lección
  09 decía `invoke_arn`). Ambas formas funcionan — su 301 en producción es la prueba
  empírica de la primera — pero divergían sin motivo.
- Tercera divergencia menor absorbida sin drama: su política se llama `read-links` (sid
  `ReadLinks`) donde la lección decía `get-links`. El mapa de la lección usa **sus** valores
  y la lección le manda verificar contra `aws iam list-role-policies`, no contra mí.

Diseño clave: el paso 0 hace el careo de gemelos con un `diff` normalizado por `sed` que
**no puede ver** los dos accidentes (viven en los nombres que el sed borra), y la lección lo
confiesa en el desplegable sin decir cuáles son: el plan del paso 5 los saca a la luz como
`~ update`. Plan esperado: `0 to add, 2 to change, 0 to destroy` + 16 mudanzas. La moraleja
enlaza con el humo de la 09: la herramienta de verificación debe cubrir el contrato entero,
y el contrato de un refactor lo cubre el plan (compara identidades contra state refrescado),
no un diff de texto.

## Decisiones de diseño de la lección

- **Retrieval en el propio refactor**: se dan 4 de los 16 `moved`; los 6 del lado Lambda los
  escribe de memoria del patrón, y la puerta entera (integraciones, rutas, permisos, outputs
  con expresión `for`) va **sin red** — solo pistas direccionales (preferencia de ejercicios
  sin supervisión). Red de seguridad honesta: un `moved` mal escrito no rompe nada, reaparece
  como pareja destruir/crear — *el plan es tu corrector*.
- **La clave del mapa es para siempre**: `"create-link"` trabaja triple (bundle, sufijo del
  function_name, dirección en el state) y renombrarla es otra mudanza. Quiz 1 lo explota.
- **`state mv` presentado sin mentir**: NO está deprecado (a diferencia del lock con
  DynamoDB — matiz importante para no gastar el patrón «casi todo internet dice lo viejo»);
  sigue siendo la herramienta para mover entre states. Para refactors internos gana `moved`
  por lo mismo que Terraform gana a la consola: revisable, repetible, ensayado por el plan.
- **Los `moved` se borran tras el apply, con criterio dicho en voz alta**: state único y un
  solo operador. La cita de la doc («removing a moved block is a breaking change») queda
  para módulos con más usuarios. El historial vive en git.
- **El módulo local se aplaza al proyecto 02, por última vez y con el criterio de la 06**:
  una estructura antes de su motivo es una manía de estilo. `for_each` ya mató la
  duplicación *dentro* del proyecto; el módulo se gana su interfaz cuando el patrón cruce
  *entre* proyectos (el 02 vuelve a necesitar «una Lambda con su rol y sus logs»). Fecha y
  cláusula de salida fijadas: si el 02 no lo justifica, se tacha del ROADMAP y se dice por qué.
- **`count` se planta como semilla** (quiz 3: identidad posicional, la cascada al borrar el
  primer elemento) para el proyecto 02, igual que la quiz 1 de la 09 plantó los `moved`.
- La pregunta del cierre (tercera función `GET /stats/{code}`) apunta a una grieta real del
  mapa de hoy: `table_actions` y `route_key` la cubren, pero devuelve JSON en vez de 301 —
  el mapa no captura *qué handler es* más allá del nombre del bundle (eso está bien: vive en
  `app/`), y sobre todo **la clave nueva no puede ser `stats`** si la ruta es
  `GET /stats/{code}`… la ruta estática convive con `{code}` por precedencia (lección 09).
  Respuesta buena esperable: una entrada de mapa + un bundle, plan de ~9 a crear, cero
  tocado en lo existente.

## Verificado ejecutándolo (2026-08-29, Terraform 1.15.8, provider aws ~> 6.0 + archive)

1. **Experimento de mudanza real** con `terraform_data` (sin credenciales): refactor a
   `for_each` sin `moved` → `2 to add, 2 to destroy`; con `moved` → las líneas exactas
   `# terraform_data.create_link has moved to terraform_data.fn["create-link"]` y
   `Plan: 0 to add, 0 to change, 0 to destroy.`; apply → `0 added, 0 changed, 0 destroyed`;
   `state list` solo con direcciones nuevas; borrar los `moved` tras el apply → `No changes`.
   Los literales del plan que enseña la lección salen de esta ejecución, no de memoria.
2. **La solución completa del refactor** (main.tf con el mapa, functions.tf, http-api.tf,
   moved.tf con los 16, outputs con expresiones `for`) escrita y validada aparte:
   `terraform validate` y `fmt -check` limpios. El `type = string` de sus outputs sigue
   validando en 1.15.8, así que no se le corrige.
3. Doc verificada el 2026-08-29: sintaxis y restricciones de `moved`
   (developer.hashicorp.com/terraform/language/moved y …/modules/develop/refactoring:
   encadenables, solo resources, «breaking change» al borrarlos en módulos publicados) y de
   `for_each` (claves conocidas en plan, sin sensitive, `toset()` explícito).

## Señales a vigilar

- **Si su plan no da `2 to change`**: no dejarle aplicar por inercia — o hay un tercer
  accidente que no vi, o no aplicó lo que creo que aplicó. Cada línea con nombre y apellido.
- **El desplegable del paso 0 le pide clasificar por escrito antes de abrir**: si trae la
  clasificación hecha, el reflejo de LR-0003 sigue vivo; si la salta, reforzar en la próxima.
- **La checklist pide decir en voz alta el criterio de borrar `moved.tf`**: es el candidato
  a pregunta de entrevista («¿y si un compañero aplica desde una rama vieja?»).
- Si pregunta por qué el provider «resube el zip» al cambiar `filename` con el mismo hash:
  respuesta corta — el atributo cambió y el update es del recurso, no del código; buena
  excusa para `terraform plan -out` + `show -json` si quiere verlo por dentro.

## Qué se escribió

- `lessons/0010-el-refactor-invisible.html` — la lección.
- `reference/terraform-refactor.html` — referencia nueva: anatomía de la dirección,
  `for_each`/`count`, `moved` vs `state mv`, la receta de seis pasos.
- ROADMAP (fila 10 publicada, fila 11 por diseñar, módulo local movido al 02 con nota),
  `reference/README.md`, GLOSSARY (3 entradas nuevas en pendientes + dirección de recurso
  religada), NOTES.
