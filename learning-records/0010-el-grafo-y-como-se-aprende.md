# Se perdió en el grafo de la Lambda, y preguntó cómo se aprende esto

2026-08-24, a mitad de la lección 05. Dos preguntas, y la segunda vale más que la primera.

## Dónde se atascó exactamente

No fue el `aws_lambda_function`: los argumentos de la función le parecieron evidentes. Fue
**todo lo que cuelga alrededor**. Sus palabras: *«no entiendo todo este grafo medio raro»*.

Diagnóstico concreto: **está mezclando dos cosas que se llaman «policy» y no se parecen en
nada.**

- `assume_role_policy`, dentro del rol → **quién puede SER el rol**. Mira hacia afuera.
- `aws_iam_role_policy`, colgado del rol → **qué puede HACER el rol**. Mira hacia adentro.

En cuanto se separan esas dos, el resto del grafo se cae solo. La analogía que funcionó: el rol
es **un uniforme con tarjeta de acceso**. La confianza dice quién puede ponérselo — por eso la
acción es `sts:AssumeRole`, ponerse el uniforme *es* asumir el rol. La identidad dice qué
puertas abre la tarjeta.

## La pregunta que hizo y que la lección no contestaba

*«¿Qué pasa si yo no quiero que escriba en CloudWatch? ¿El rol es obligado?»*

La lección daba por hecho que los cuatro recursos hacían falta. **No es cierto, y la distinción
importa:**

| Recurso | ¿Obligatorio? | Si falta |
|---|---|---|
| `aws_iam_role` + confianza | **Sí** | El `apply` falla: `role` es argumento requerido de la API |
| `aws_iam_role_policy` | **No** | La función corre perfectamente y es **muda** |
| `aws_cloudwatch_log_group` | **No** | Lambda lo crea sola, sin retención, fuera del state |

Y la respuesta literal: **no hay interruptor para apagar los logs; la ausencia del permiso *es*
el interruptor.** El rol, en cambio, no es negociable — igual que un proceso de Unix corre
siempre como algún usuario aunque ese usuario no pueda hacer nada.

## La segunda pregunta, que es la buena

*«No entiendo cómo este tipo de cosas se aprenden. En la UI es muy fácil, te va guiando.»*

Es la primera vez que pregunta por el **método**, no por el contenido. Merecía una respuesta
honesta y con fuente, no un «con práctica».

**La respuesta:** la consola no era más simple. Le estaba escribiendo el mismo código sin
enseñárselo. Está literal en la doc de AWS — al configurar el grupo de logs desde la consola,
*«Lambda añade este permiso al rol… le da a la función permiso para enviar logs a **cualquier**
log group de CloudWatch»*, y hay una casilla («Add required permissions») para impedirlo que
casi nadie sabe que existe. Con la AWS CLI no lo hace.

Corolario que hay que repetirle cuando vuelva a sentirse abrumado: **la IaC no añade
complejidad, revela la que la consola escondía — y la escondía mal.** Cada Lambda que borró por
consola dejó su log group huérfano sin retención.

## Lo que se le dio como método, y hay que reutilizar

Tres bucles, ninguno es un tutorial:

1. **El bucle del error.** Cada `AccessDenied` enseña una arista del grafo. Ya lo vivió con el
   `.tflock` en la lección 04.
2. **El bucle consola → código.** Constrúyelo con clics, luego `import` +
   `terraform plan -generate-config-out`. Es la técnica que responde su pregunta entera, y la
   pidió explícitamente con comandos. Escrita en `reference/terraform-cli.html#autopsia`.
3. **El bucle del `destroy`.** Lo que sobrevive te enseña qué nunca fue tuyo.

Y **la pregunta de tres partes** para cualquier recurso de AWS que ejecute algo — Lambda, ECS,
EC2, CodeBuild, EventBridge:

1. ¿Con qué identidad actúa? → un rol, siempre.
2. ¿Quién puede usar esa identidad? → la política de confianza. **Cambia el principal y tienes
   ECS, o GitHub Actions, u otra cuenta: la forma es idéntica.**
3. ¿Sobre qué recursos actúa, y quién los crea? → la política de identidad, más los recursos
   destino que tendrá que declarar él.

No se memoriza el grafo: se deriva. Esto es vocabulario compartido a partir de ahora — cuando
llegue a ECS en el proyecto 06 o a OIDC en el 07, se presenta como «las mismas tres preguntas,
otro principal», igual que se hizo con los cuatro niveles del arranque
([LR-0008](./0008-niveles-del-arranque.md)).

## Qué se escribió

- `reference/aws-lambda.html`: sección nueva **«Por qué son cuatro recursos y no uno»** con un
  diagrama SVG del grafo (aristas continuas = referencias que Terraform deduce; discontinuas =
  `depends_on`), la tabla de las dos políticas, la tabla de obligatorio/opcional, y el aviso
  citado de lo que la consola hace con tu rol.
- `reference/terraform-cli.html`: sección nueva **«Cuando no sabes qué recursos hacen falta»**
  con la autopsia en dos pasos —seis comandos de la AWS CLI tirando del hilo, y luego los
  bloques `import` con `-generate-config-out`—, los `id` de import de los cuatro recursos, y
  qué buscar en el fichero generado.

Verificado: el HCL de la autopsia pasa `terraform validate`, y `-generate-config-out` sigue
etiquetado como **experimental** en su 1.15.8 (se lo dije, en vez de venderlo como estable).

## Señal a vigilar

Dijo *«tienes que como ser muy consciente de cada cosa»* con tono de queja. Es exactamente la
habilidad que la misión pide —saber *por qué* está cada pieza, no solo el cómo— así que hay que
nombrárselo cuando le pese: la incomodidad que siente **es** el aprendizaje, y es lo que le
separará en una entrevista de quien solo ha usado la consola. Pero no repetirlo como consuelo
vacío: acompañarlo siempre de una herramienta concreta, como se hizo aquí.
