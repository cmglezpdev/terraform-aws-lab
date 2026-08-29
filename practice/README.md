# Práctica sin supervisión

Esta sección existe para lo que las lecciones no pueden darte: **desarrollar sin que nadie
te guíe**. En las lecciones yo decido cada paso; aquí solo recibes un objetivo, unos
requisitos y unas pistas. Todo lo demás —leer la doc del provider, equivocarte, leer el
error, corregir— es tuyo. Ese es el punto: la fluidez de seguir una lección no es lo mismo
que saber construir, y lo segundo solo se entrena así.

No sustituye al roadmap: lo acompaña. Un ejercicio por día (o por sesión suelta), en
paralelo con las lecciones normales.

## Cómo se trabaja

1. Elige un ejercicio de la tabla (respeta los prerequisitos).
2. Lee su `BRIEF.md`. **Tu solución vive dentro de la misma carpeta del ejercicio**
   (`practice/NN-slug/`), junto al brief: ahí van tus `.tf`, tu `app/` si hay código, todo.
3. Diseña, despliega, **verifica con los comandos del brief**, y destruye.
4. Cuando lo des por terminado, marca la casilla en la tabla y pídeme revisión en una
   sesión aparte: *«revísame el ejercicio NN»*. Yo lo evalúo contra mi rúbrica y lo
   comentamos.

### El sistema de honor

En [`rubrics/`](./rubrics/) está lo que voy a evaluar de cada ejercicio: el checklist, las
trampas que espero, el listón. **No lo leas antes de la revisión.** El brief ya trae pistas
orientativas; si además lees la rúbrica, el ejercicio se convierte en rellenar casillas y
pierdes exactamente lo que esta sección entrena. Después de la revisión, léela entera.

## Los ejercicios

| # | Ejercicio | Servicios | Dificultad | Tiempo | Prerequisito | Hecho |
|---|---|---|---|---|---|---|
| 01 | [El rol auditor](./01-el-rol-auditor/BRIEF.md) | IAM, STS | ●○○ | ~45 min | Lección 04 | ☐ |
| 02 | [El bucket de artefactos](./02-el-bucket-de-artefactos/BRIEF.md) | S3, IAM | ●○○ | ~45-60 min | Lección 04 | ☐ |
| 03 | [El candado de despliegue](./03-el-candado-de-despliegue/BRIEF.md) | DynamoDB | ●●○ | ~60 min | Lección 07 | ☐ |
| 04 | [La cadena de invocación](./04-la-cadena-de-invocacion/BRIEF.md) | Lambda ×2, IAM, CloudWatch Logs | ●●○ | ~60-90 min | Lección 06 | ☐ |
| 05 | [El artefacto desde S3](./05-el-artefacto-desde-s3/BRIEF.md) | Lambda, S3, IAM | ●●○ | ~60-90 min | Ejercicio 02 | ☐ |
| 06 | [La autopsia](./06-la-autopsia/BRIEF.md) | DynamoDB, CloudWatch Logs, Terraform `import` | ●●○ | ~60-90 min | Lección 07 | ☐ |
| 07 | [La puerta de operaciones](./07-la-puerta-de-operaciones/BRIEF.md) | API Gateway, Lambda, DynamoDB | ●●● | ~90 min | ⚠️ **Lección 08** | ☐ |

El orden es una recomendación, no una obligación — salvo las flechas duras: el 05 necesita
el bucket del 02, y el 07 necesita haber cursado la lección 08.

## Reglas comunes a todos

- **Backend remoto siempre.** Mismo bucket de state del curso; la key la decides tú, pero
  antes de inventártela relee la política `terraform-course` del proyecto 00 — tiene una
  opinión sobre cómo puede llamarse, y el error que da si no la respetas es instructivo.
- **Prefijo `practice-NN-`** en todos los recursos con nombre, para que nunca choquen con
  los proyectos del roadmap.
- **Coste ~0**: todo lo que se usa aquí es pago por uso. Aun así, cada brief declara su
  coste y **cada ejercicio termina con `terraform destroy` verificado** — comprobar que no
  queda nada es parte del ejercicio, no un trámite.
- **TypeScript** donde haya código, con tu cadena de siempre: pnpm 11, TS 7, esbuild, ESM.
- Los briefs que estrenan acciones nuevas te recuerdan **ampliar antes la política del
  proyecto 00** — el precedente de la lección 07 (`dynamodb:*`) aplica aquí igual.

## El cuestionario

La otra mitad de la práctica: [`quiz/index.html`](./quiz/index.html) — ábrelo en el
navegador (doble clic vale, no necesita red). Eliges los temas y te tira preguntas
aleatorias con corrección inmediata. Úsalo en los huecos que no dan para un ejercicio.

## Esta sección crece

Cuando el curso toque servicios nuevos (SQS y EventBridge en el proyecto 02, VPC en el 04…)
se añaden ejercicios nuevos aquí. Si un ejercicio te parece de juguete o demasiado grande,
dímelo: se rediseña — ya hay precedente.
