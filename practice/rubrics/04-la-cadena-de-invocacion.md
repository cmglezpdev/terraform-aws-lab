# Rúbrica 04 — La cadena de invocación

> **No leer antes de la revisión.**

## Checklist

- [ ] Dos roles, dos políticas de logs, cada una con SU ARN de log group **con `:*`**
      añadido a mano (la trampa central de la lección 05; aquí hay que esquivarla dos
      veces). Cero `Resource: "*"` en logs.
- [ ] `lambda:InvokeFunction` solo en el rol de greeter, `resources` =
      `[aws_lambda_function.normalizer.arn]` por referencia. Ni `*`, ni ARN pegado.
- [ ] Env var (`NORMALIZER_FUNCTION_NAME` o similar) por referencia → dependencia
      implícita; ningún `depends_on` gratuito entre las funciones.
- [ ] `.tf` partidos por componente (greeter / normalizer / main / outputs) — el criterio
      que él mismo pidió en el proyecto 01.
- [ ] arm64 en ambas; banner `createRequire` en greeter (lleva SDK); humo desde `.mjs`.
- [ ] Tests sin AWS. Frontera esperable: la normalización en `domain/` puro; la
      invocación como puerto en greeter con fake en tests, o —igual de válido con
      argumento— greeter sin tests unitarios y la cadena verificada por despliegue,
      citando el precedente del `handler.test.ts` borrado. Lo que evalúo es el argumento,
      no la opción.
- [ ] Prueba negativa del privilegio elegida y ejecutada. Opciones dignas: invocar desde
      greeter una tercera función/ARN inexistente y enseñar el `AccessDenied` (código
      temporal de prueba), o asumir el rol de greeter vía STS (si hizo el ejercicio 01,
      conectará solo: añadir su usuario a la confianza del rol) e invocar otra cosa.
      Lo que no vale: «no puede porque la política lo dice» — LR-0003.
- [ ] Destroy sin huérfanos, comprobado con `aws logs describe-log-groups`.

## Trampas que espero

- **El `Payload` del SDK es `Uint8Array`**: el `JSON.parse(payload)` directo revienta o
  da `[object Object]`. La solución idiomática es `Buffer.from(...).toString()` o
  `transformToString`. Es la pista 2; quiero ver cómo la resolvió.
- **El banner del `createRequire`**: si lo olvidó, `Dynamic require of "node:https"` en
  runtime — segunda mordida de la misma serpiente. Su humo desde `.mjs` debería cazarlo
  antes del apply; si el humo lo cazó, el sistema funcionó y vale oro contarlo así.
- `FunctionError` en la respuesta con status 200: invocar-con-error **no es un error de
  transporte**. Si normalizer lanza, greeter recibe 200 + `FunctionError: Unhandled`.
  ¿Lo maneja o lo ignora?
- Un solo rol para las dos «por simplicidad» — violación directa del requisito 2 y de
  «agrupa por permisos».
- Parameter properties de TS en clases nuevas (`ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX`) si
  ejecuta tests con Node directo — LR-0011.

## El listón

Que responda la pregunta de tres partes **para cada función** sin mirar apuntes, y que
sepa decir qué demuestra su prueba negativa y qué no. El grafo doble debe poder dibujarlo.

## Preguntas de la revisión

1. «¿Por qué el permiso de invocar vive en la política de identidad de greeter y no en
   una política de recurso de normalizer? ¿Podría vivir allí?» (sí podría —
   `aws_lambda_permission` con `principal` el rol— pero mismo­-cuenta basta la identidad;
   quiero que distinga las dos rutas y sepa que existen ambas, enlaza con lección 08).
2. «Si normalizer tarda 30 s, ¿qué le pasa a greeter y quién paga?» (espera síncrona,
   greeter facturando GB-segundo mientras espera — el porqué las cadenas largas se hacen
   con colas, proyecto 02).
3. «¿Qué pasa si borro la env var y pongo el nombre de la función a pelo en el código?»
   (funciona… hasta que no: se pierde la arista del grafo, el orden de creación, y la
   configuración vuelve a estar enterrada en el artefacto).
