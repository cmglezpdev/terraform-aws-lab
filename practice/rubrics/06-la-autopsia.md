# Rúbrica 06 — La autopsia

> **No leer antes de la revisión.**

## Checklist

- [ ] Bloques `import` declarativos con `to`/`id` correctos: tabla → `practice-06-inventory`
      (el nombre), log group → `/practice/06/legacy-app` (el nombre con barras). El
      `imports.md` recoge la asimetría de formatos.
- [ ] `generated.tf.bak` conservado; el diff generado→final es sustancial (lo generado
      trae `read_capacity`/`write_capacity` en 0, `ttl` vacío, `point_in_time_recovery`,
      `stream_enabled`, tags nulos…). Configuración final esperable: ~10-15 líneas.
- [ ] `plan` con **No changes** capturado antes del cambio de retención.
- [ ] El cambio de retención 30→7 aplicado desde Terraform como *update in-place* (`~`),
      no como replace.
- [ ] Ningún `destroy and create replacement` aceptado por el camino. Si le apareció
      (típico: tocar algo del `key_schema`/`attribute` al podar de más), ¿entendió por
      qué ese cambio es ForceNew?
- [ ] La reflexión del ítem muerto en el destroy final existe (adoptar te da el poder de
      borrar datos que no creaste — `deletion_protection_enabled` / `prevent_destroy`
      mencionados vale oro, no lo exijo).

## Trampas que espero

- **Podar de más**: quitar `billing_mode` porque «PAY_PER_REQUEST ya lo pone la CLI» —
  el default del provider es `PROVISIONED`, así que sin la línea el plan quiere cambiar
  la tabla. Es «el default del provider no es tu default» en su forma más pura: aquí el
  default de la CLI de AWS y el del provider **no coinciden**, y la configuración mínima
  correcta es la que fija lo que difiere del default *del provider*, no del mundo.
- **Podar de menos**: dejar el `generated.tf` casi entero «por si acaso» — incumple el
  requisito 4 y delata que no decidió nada.
- Creer que el `import` escribe configuración (solo escribe state; la config es
  `-generate-config-out` o tu mano).
- El log group importado con retención: si al podar elimina `retention_in_days = 30`, el
  plan querrá ponerla a «nunca expira» — drift autoinfligido y silencioso.

## El listón

Que el fichero final se lea como si él lo hubiera escrito de cero, y que pueda justificar
**cada línea** con «difiere del default del provider» o «lo fijo a conciencia porque…».
La autopsia es de la lección 05/LR-0010; ejecutarla solo era la deuda pendiente del
«¿cómo se aprende esto?».

## Preguntas de la revisión

1. «¿Qué hay en el state de un recurso importado que no hay en tu `.tf`?» (todo: el
   state guarda cada atributo; la config solo declara lo que tú fijas — y el plan compara
   ambos contra la realidad refrescada).
2. «Si el compañero imaginario sigue tocando la tabla por consola después de tu
   adopción, ¿qué lo detecta y cuándo?» (el refresh del siguiente plan = drift; nada te
   avisa en tiempo real — enlaza con el post-mortem prometido del proyecto 03).
3. «¿Por qué el ejercicio prohibió `terraform import` imperativo?» (el bloque es
   revisable en un PR, repetible, y vive con la config; el comando es un acto sin
   historia — mismo argumento que IaC entera).
