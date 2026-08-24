# Preguntó por los niveles del arranque privilegiado, y detectó el atajo del curso

2026-08-24, durante la lección 04. Tres preguntas seguidas, y las tres eran la misma pregunta
de fondo: *¿por qué la identidad se crea con el mismo Terraform que después la usa?*

## Lo que vio por su cuenta

- Que el primer `apply` de cualquiera que clone el repositorio **tiene que ser con root**, y
  que eso no es un defecto del tutorial sino una propiedad de AWS.
- Que la alternativa razonable es **un proyecto de bootstrap aparte** que se ejecuta con la
  llave privilegiada y crea las identidades, para que los demás proyectos usen una sola
  credencial acotada.
- Que el mismo problema se repite con la activación del acceso de IAM a la facturación.

Es la primera vez que anticipa una decisión de arquitectura antes de que se la enseñe. Vale
la pena decírselo cuando vuelva a pasar.

## Donde su modelo se quedaba corto

Propuso que, para ampliar un permiso, «se le pide a la persona que tiene root». En una
organización real eso no ocurre: **los permisos son código en un repositorio aparte y
ampliarlos es un pull request** que aplica un pipeline con más privilegios. La escalada
existe —tiene que existir— pero es un commit revisado, no un mensaje por Slack.

Ese fue el único salto conceptual que hubo que darle. El resto lo tenía.

## Corrección a la lección: no, no vuelve a necesitar root

Preguntó si, al añadir servicios nuevos en el proyecto 01, tendrá que volver a
`personal-root` para adjuntar permisos. **No**, y la lección no lo decía:

- Tiene `iam:*`, así que modificar su propia política es una acción que ya puede hacer. Añade
  las acciones de Lambda y DynamoDB y aplica con `personal`.
- Root solo hace falta cuando **lo roto impide el `apply` en sí** (el backend, el bucket de
  state, su propia identidad) o cuando la tarea es de la lista exclusiva de root.

Y la observación honesta que hay que repetirle: **la comodidad y el agujero son la misma
cosa.** El `iam:*` que le ahorra volver a root es el que le deja adjudicarse
`AdministratorAccess`. En el modelo serio la identidad que ejecuta Terraform a diario no
tiene permisos de IAM, y por eso ampliarlos cuesta un PR.

## Qué se añadió a la lección

Dos secciones nuevas al final, antes del quiz:

1. **«¿Y cuándo vuelvo a necesitar root?»** — las dos únicas condiciones, y el aviso de que
   la conveniencia de `iam:*` es el propio agujero.
2. **«El problema del arranque, en el mundo real»** — tabla de cuatro niveles: 0 módulo raíz
   que crea a su sucesor (hoy), 1 bootstrap aparte, 2 rol asumible con
   `provider "aws" { assume_role {} }`, 3 organización con Identity Center, OIDC y SCP.

La lección pasa de 40 a 45 minutos. Es lectura, no ejecución, y va al final: si se queda sin
tiempo, se lee otro día sin romper nada.

## Reflejo que hay que seguir alimentando

Iba a reportar que el `plan` **no** había fallado, y se dio cuenta él solo, escribiendo, de
que seguía con el perfil de root. Se corrigió sin ayuda. Es exactamente por lo que toda
lección empieza con `aws sts get-caller-identity`, y hay que nombrárselo cuando pase, igual
que en [LR-0003](./0003-el-apply-no-es-la-prueba.md).

## Consecuencia para el proyecto 07

Cuando llegue, ya tiene el mapa mental montado. El 07 debe presentarse explícitamente como
«subir del nivel 0 al nivel 3 de esta tabla», y no como material nuevo — usa la misma tabla
como índice. Ver también [LR-0007](./0007-usuario-iam-sin-claves.md).
