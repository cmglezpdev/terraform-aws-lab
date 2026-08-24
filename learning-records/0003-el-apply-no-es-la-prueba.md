# El `apply` correcto no demuestra que el sistema funcione

Al terminar la lección 01 el usuario detectó por su cuenta que **no le había llegado el correo
esperado** y preguntó si había forma de probarlo. Esa pregunta —«¿cómo pruebo esto?»— es la
señal de aprendizaje más valiosa de la sesión: es el reflejo que separa a quien despliega
infraestructura de quien copia tutoriales.

Al investigarlo aparecieron dos hechos, uno mío y otro de AWS:

1. Yo afirmé en la lección 01 que AWS enviaría un correo de confirmación de suscripción con
   `subscriber_email_addresses`. No es fiable ni observable. **Lección 01 corregida en sitio.**
2. Las alarmas `FORECASTED` de AWS Budgets **no se disparan** hasta que la cuenta acumula unas
   5 semanas de historial de uso
   ([fuente](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-best-practices.html)).
   La red de seguridad principal del curso estaba creada e inerte.

## Implicaciones

- El principio **«el `apply` ha funcionado» ≠ «funciona»** queda establecido como eje del
  curso. Toda infraestructura desplegada de aquí en adelante debe llevar un paso de
  verificación explícito, y hay que decir siempre **qué cubre el test y qué no**.
- Sirve como precedente directo para: health checks de ALB (proyecto 04), failover de RDS
  (proyecto 04), y DLQ de SQS (proyecto 02). En los tres, el `apply` sale limpio y el sistema
  puede no funcionar.
- El usuario responde bien a que se le corrija abiertamente un error mío. Mantener esa
  política: corregir en sitio la lección afectada y decirlo sin rodeos.

## Evidencia

Detectó la discrepancia entre lo prometido y lo observado sin que se le pidiera, y pidió un
método de prueba en lugar de una explicación.
