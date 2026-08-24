# Mission: Terraform aplicado a AWS

## Why
Los puestos a los que aplico piden Terraform y AWS, y hoy no puedo respaldar esa
respuesta con nada concreto. Quiero llegar a una entrevista con un repositorio
público en mi GitHub que demuestre que he diseñado, desplegado y destruido
infraestructura real en AWS con Terraform — no tutoriales de un bucket S3, sino
arquitecturas con varios servicios donde se ve *por qué* está cada pieza.

## Success looks like
- Puedo explicar en una entrevista, con un diagrama y el código delante, por qué una
  Lambda va en una subnet privada, qué hace un NAT Gateway y cuánto cuesta.
- Levanto una arquitectura de varios servicios con `terraform apply` y la tumbo entera
  con `terraform destroy` sin dejar recursos huérfanos ni facturas sorpresa.
- Escribo módulos Terraform reutilizables y despliego el mismo código en `dev` y `prod`
  sin duplicarlo.
- Sé qué es el state, dónde vive, por qué se bloquea y qué hacer cuando se corrompe.
- Tengo un repo público con 6+ proyectos documentados, cada uno con su diagrama,
  su coste estimado y su justificación de diseño.

## Constraints
- **Sesiones de 30-45 min, casi diarias.** Cada lección debe caber ahí, entera.
- **Presupuesto ~30 USD/mes** en la cuenta personal `999999999999`. Todo se destruye al
  terminar la sesión. Cada proyecto declara su coste por hora antes de aplicarse.
- **TypeScript** para todo el código de aplicación (Lambdas, workers, scripts). Nada de
  JavaScript plano, Java, Go ni Python.
- Conocimientos de AWS: básicos pero reales. Terraform: he aplicado tutoriales sueltos,
  sin entender bien state, módulos ni workspaces.
- El repo será público en GitHub → cero secretos en el código, cero state en git.

## Out of scope
- Certificaciones AWS (SAA, etc.). El objetivo es saber hacer, no aprobar un examen.
- CDK, Pulumi, CloudFormation, Serverless Framework. Solo Terraform.
- Terraform Cloud / HCP de pago. El backend es S3 en mi propia cuenta.
- Optimización de costes a escala, FinOps, y compliance (SOC2, HIPAA).
