# Restricciones operativas del curso: cuenta, coste y ritmo

Decisiones acordadas en la sesión inicial (2026-08-23) que condicionan el diseño de todas
las lecciones futuras.

- **Cuenta AWS**: una cuenta personal dedicada al curso, con su propio perfil local. Arranca
  con las credenciales iniciales de la cuenta; crear una identidad IAM dedicada para Terraform
  es una de las primeras cosas que corrige el proyecto 00.
  Existe una segunda cuenta de trabajo que **no se usa** en el curso: por eso toda lección
  empieza comprobando `aws sts get-caller-identity`.

  _(Los identificadores de cuenta de este repositorio son marcadores de posición: el
  repositorio es público.)_
- **Techo de gasto: ~30 USD/mes.** Suficiente para tocar EKS, NAT Gateway, ALB y RDS en
  sesiones cortas y reales. El modelo operativo es siempre `apply` → probar → `destroy`.
- **Sesiones de 30-45 minutos, casi diarias.** Esto es la restricción más fuerte del diseño:
  ninguna lección puede exceder ese tamaño, y los proyectos caros (04, 06) tienen que
  partirse de forma que cada sesión termine con la infraestructura destruida.

## Implicaciones

- El ritmo diario favorece **spacing y retrieval**: cada lección debe abrir recuperando algo
  de la anterior, sin releerlo.
- Los proyectos 04 (`vpc-three-tier`) y 06 (`eks-platform`) necesitan que la fase de
  escritura de código y la de `apply` estén **en sesiones distintas**, para que el reloj
  solo corra en la segunda.
- El repositorio será **público en GitHub**. Ninguna lección puede sugerir escribir un
  secreto, un ARN de cuenta sensible o un correo dentro de un fichero versionado.
