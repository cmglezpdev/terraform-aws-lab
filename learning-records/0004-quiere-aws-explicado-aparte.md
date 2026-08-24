# Quiere el AWS explicado como bloque propio, no diluido en el Terraform

Petición explícita del usuario (2026-08-23): las lecciones deben tener **secciones separadas
dedicadas a cada servicio de AWS** que respondan qué es, para qué sirve, qué tipos hay, cómo
funciona y cuánto cuesta — con sus propias preguntas de comprobación.

Cita textual: *"la idea aqui por ejemplo es saber para que son las alertas, cuales son los
tipos que hay, como funcionan, cuanto cuestan y así con todos los demas servicios de aws que
usemos"*.

Esto **refina la misión sin cambiarla**: sigue siendo Terraform aplicado a AWS, pero el usuario
está diciendo que el conocimiento de AWS no puede quedar implícito en el HCL. Quiere poder
responder en una entrevista «¿qué tipos de X hay y cuándo usas cada uno?», que es justo lo que
no se aprende leyendo código de infraestructura.

## Implicaciones

- Creado el skill [`aws-service-explainer`](../.claude/skills/aws-service-explainer/SKILL.md),
  que fija las ocho preguntas obligatorias, exige verificar toda cifra contra la documentación
  de AWS o la Price List API, y obliga a incluir una sección **«cuándo NO usarlo»**.
- Formato doble: referencia autónoma en `reference/aws-<servicio>.html` (lo que reconsulta) y
  sección `.anatomy` comprimida dentro de la lección (lo que lee en el momento).
- La sección de **coste** debe distinguir siempre lo que cobra por hora esté o no en uso de lo
  que es pago por uso. Es lo que determina si puede dejar algo desplegado, y es la restricción
  operativa nº 1 del curso.
- Ritmo: esto **alarga cada lección**. Con sesiones de 30-45 min, la anatomía embebida tiene
  que quedarse en las preguntas 1, 3 y 5; el resto vive en la referencia.
