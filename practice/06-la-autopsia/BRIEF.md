# Ejercicio 06 — La autopsia

> Dificultad ●●○ · ~60-90 min · Servicios: DynamoDB, CloudWatch Logs · Terraform `import`
> Prerequisito: [lección 07](../../lessons/0007-la-memoria-del-acortador.html)

## Contexto

Pregunta real de entrevista, casi palabra por palabra: *«tenemos infraestructura creada a
mano hace años; ¿cómo la meterías en Terraform?»*. La técnica la tienes fichada desde la
lección 05 —la autopsia consola → código— pero nunca la has ejecutado entera tú solo.
Hoy heredas la infra de un compañero imaginario que no usaba IaC, y la **adoptas** sin
recrearla: al final, Terraform es el dueño y no ha destruido ni recreado nada.

## El escenario

Ejecuta esto tal cual (es la herencia; no lo escribas en Terraform):

```sh
aws dynamodb create-table \
  --table-name practice-06-inventory \
  --attribute-definitions AttributeName=sku,AttributeType=S \
  --key-schema AttributeName=sku,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --profile personal

aws logs create-log-group --log-group-name /practice/06/legacy-app --profile personal
aws logs put-retention-policy --log-group-name /practice/06/legacy-app \
  --retention-in-days 30 --profile personal

aws dynamodb put-item --table-name practice-06-inventory \
  --item '{"sku":{"S":"SKU-001"},"stock":{"N":"7"}}' --profile personal
```

Ese `put-item` final importa: la tabla tiene **datos**. Adoptar no puede costar ni un
ítem.

## Lo que vas a hacer

1. Adoptar la tabla y el log group con bloques `import` +
   `terraform plan -generate-config-out=generated.tf`.
2. Convertir lo generado en configuración **tuya**: limpia, mínima, con nombres de
   recurso decentes — hasta que `terraform plan` diga **No changes**.
3. Demostrar la propiedad: cambia la retención del log group a 7 días **desde Terraform**
   y aplica. Un cambio limpio sobre infra que Terraform no creó — eso es la adopción
   consumada.
4. `destroy` final: ahora sí, Terraform borra lo que nunca creó. Comprueba que el ítem
   murió con la tabla (y anota la reflexión que eso te provoque).

## Requisitos obligatorios

1. Backend remoto, key propia.
2. Bloques `import` en fichero (la forma declarativa de la lección), no `terraform
   import` imperativo por CLI.
3. El `generated.tf` crudo **se guarda** (renómbralo a `generated.tf.bak` al terminar):
   en la revisión compararemos lo que la máquina vomitó con lo que tú dejaste.
4. Tu configuración final no puede contener ningún argumento que esté en su valor por
   defecto *salvo* los que tú decidas fijar a conciencia — y esos, con un comentario de
   una línea. («Lo generó la máquina» no es un porqué.)
5. `plan` limpio (**No changes**) antes del paso 3, capturado.
6. Un `imports.md` corto en la carpeta: qué `id` usa cada tipo de recurso para importarse
   (no es obvio y no es uniforme — esa asimetría es apunte de entrevista).

## Restricciones

- No borres y recrees nada: si el `plan` propone `destroy and then create replacement`
  en algún momento, ese es el bug a resolver, no a aceptar.
- `-generate-config-out` sigue marcado **experimental** en tu 1.15.8: revisa lo generado
  con lupa, que para eso está el ejercicio.
- Coste: ~0.

## Verificación — esto lo demuestra, esto no

```sh
terraform plan   # → "No changes." — la adopción sin drift
aws dynamodb get-item --table-name practice-06-inventory \
  --key '{"sku":{"S":"SKU-001"}}' --profile personal   # → el ítem sigue vivo tras adoptar
aws logs describe-log-groups --log-group-name-prefix /practice/06 \
  --profile personal   # → retentionInDays: 7 tras el paso 3
```

El «No changes» demuestra que tu HCL describe exactamente lo que hay. **No** demuestra
que entiendes lo que hay — eso lo demuestra el paso 4 del requisito: cada línea
superviviente con su porqué.

## Antes de empezar

Nada que ampliar: `dynamodb:*` y `logs:*` ya están en tu política.

## Pistas

- El curso ya te dejó escrita la secuencia completa de la autopsia, con los seis comandos
  del hilo y qué buscar en lo generado. Está donde siempre han estado las herramientas
  de la CLI. Úsala como mapa, no como solución: tus recursos son otros.
- Lo generado viene con TODO: cada default, cada `null`, cada bloque vacío. Tu criterio
  para podar ya lo tienes de la lección 07 — piensa qué pasó allí con los atributos que
  sobraban, y qué diferencia hay entre un argumento en su default y un argumento que tú
  fijas.
- El `id` de import de un log group no se parece al de una tabla. Cuando dudes del
  formato, el final de la doc de cada recurso del provider siempre lo dice.

## Dónde investigar

- [`terraform-cli.html#autopsia`](../../reference/terraform-cli.html#autopsia) — tu mapa.
- Terraform: [el bloque `import`](https://developer.hashicorp.com/terraform/language/import) ·
  [generar configuración](https://developer.hashicorp.com/terraform/language/import/generating-configuration)
- Provider: [`aws_dynamodb_table`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/dynamodb_table.html.markdown) ·
  [`aws_cloudwatch_log_group`](https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/cloudwatch_log_group.html.markdown)
  (sección *Import* de cada uno)

---

*¿Atascado de verdad (30+ min sin avanzar)? Pregúntame en el chat — orientar no es resolver.*
