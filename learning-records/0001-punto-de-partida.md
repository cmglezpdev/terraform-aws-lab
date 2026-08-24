# Punto de partida declarado: AWS básico, Terraform de tutoriales

El usuario declara conocimientos **básicos pero reales de AWS** (sabe qué son Lambda, SQS,
EventBridge, SNS, EC2, EKS, RDS, DynamoDB, CloudFront y load balancers, y los nombra sin
titubear) y de **Terraform ha aplicado tutoriales sueltos**: sabe la sintaxis básica y ha
ejecutado `apply`, pero no entiende state, módulos ni workspaces.

Cree explícitamente que "Terraform es bastante sencillo y la complejidad está en configurar
AWS". Eso es **parcialmente falso** y hay que corregirlo con evidencia, no con discurso: la
dificultad real de Terraform está en el state (drift, locks, `import`, `state mv`), en el
diseño de módulos y en la gestión de múltiples entornos. Ninguna de esas tres cosas aparece
en los tutoriales que ha hecho, y las tres son lo que se pregunta en entrevistas.

## Implicaciones

- No empezar por sintaxis HCL: la conoce. Empezar por el **modelo mental de las tres
  realidades** (configuración / state / AWS), que es donde está el hueco.
- Los ejercicios de un solo recurso le desmotivan activamente ("no le veo el caso de uso").
  Todo debe estar embebido en un proyecto con razón de existir.
- Su nivel de AWS permite ir directo a arquitecturas de varios servicios sin explicar qué es
  una Lambda desde cero. Sí hay que explicar el **porqué de las decisiones de diseño**
  (System Design), que es lo que declara querer.
- Punto ciego probable: redes (VPC, subredes, route tables, NAT). Lo menciona como algo que
  quiere aprender, nunca como algo que ya sabe. El proyecto 04 debe ir despacio ahí.

## Evidencia

Declaración propia en la sesión inicial (2026-08-23) y respuesta a la pregunta de
calibración: *"He aplicado tutoriales sueltos — sé la sintaxis básica pero no entiendo bien
state, módulos ni workspaces."*
