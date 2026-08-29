# Rúbrica 03 — El candado de despliegue

> **No leer antes de la revisión.**

## Checklist

- [ ] Tabla mínima: solo `lock_id` en el bloque `attribute`. Si declaró también `owner` y
      `acquired_at`, cayó en **la trampa del plan infinito** de la lección 07 — y el
      síntoma no aparece hasta el segundo `plan`. ¿Lo vio? ¿Lo entendió?
- [ ] `billing_mode = "PAY_PER_REQUEST"` explícito + frase del porqué (el default
      `PROVISIONED` cobra por hora — «el default del provider no es tu default» nº 2).
- [ ] La demostración del upsert silencioso existe y está guardada ANTES de la protección.
      Es requisito 3; sin ella, el ejercicio pierde su mitad pedagógica.
- [ ] Adquirir: `attribute_not_exists(lock_id)`. Liberar: condición de igualdad sobre
      `owner` (p. ej. `#o = :me` con `expression-attribute-names` si hace falta).
- [ ] Colisión → `ConditionalCheckFailedException` capturada literal.
- [ ] `protocol.md`/script reproducible, comandos completos.
- [ ] El README nombra el problema del candado huérfano (proceso muerto sin liberar) y
      esboza salida (TTL / expiración por timestamp comparado en la condición). No exijo
      implementación — TTL no está dado; llega en el proyecto 03.

## Trampas que espero

- **El bloque `attribute` como esquema** — la trampa está invitada a propósito: el
  protocolo usa `owner`/`acquired_at` y el reflejo SQL pide declararlos.
- `delete-item` sin condición «porque borrar parece inofensivo» — liberar el candado
  ajeno es el mismo upsert disfrazado.
- Confundir `ConditionalCheckFailedException` (la condición hizo su trabajo) con un
  error de su comando. Si «arregló» la colisión hasta que dejó de fallar, entendió al
  revés: aquí el fallo es el éxito.
- El flag de la pista es `--return-values-on-condition-check-failure ALL_OLD`. Punto
  extra si lo encontró; cero drama si no.

## El listón

Que pueda explicar **por qué esto es atómico sin transacciones**: la condición se evalúa
dentro de la escritura, no antes (no hay carrera get→put). Y que conecte solo el patrón
con su `.tflock` — la frase «esto es lo que hace mi backend» debería salir de él.

## Preguntas de la revisión

1. «¿Por qué un `get-item` para comprobar y luego `put-item` NO vale, aunque los hagas
   seguidos?» (ventana de carrera; la condición viaja con la escritura).
2. «¿Qué diferencia hay entre este candado y el `use_lockfile` de tu backend?» (mismo
   patrón, otro almacén; S3 lo hace hoy con If-None-Match — no exijo ese detalle, sí que
   vea la equivalencia funcional).
3. «Enséñame el segundo `plan` de tu tabla. ¿Por qué está limpio?» (si declaró atributos
   de más, no lo estará — y la conversación sale sola).
