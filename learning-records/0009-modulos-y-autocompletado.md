# Decidió aprender a mano antes que con módulos, y pidió cómo descubrir valores válidos

2026-08-24, al cerrar el proyecto 00. Tres preguntas conceptuales, ninguna de ellas sobre la
lección: por qué escribir tanto código para un usuario IAM, cómo se averigua qué acepta cada
argumento, y qué es exactamente un `data`.

## La decisión que tomó él, y que hay que respetar

Sabe que existen módulos de la registry y **prefiere seguir a mano** hasta entender lo que
esconden. Sus palabras: *«quiero saber hasta qué punto todo se hace a mano para poder
entender y aprender»*.

Es la decisión correcta y coincide con el roadmap tal y como está: el proyecto 01 escribe un
**módulo local** propio, y el 04 es el primero que consume **módulos de la registry**. No
adelantarlo. Cuando llegue el 04, el argumento a usar es el que él mismo dio: un módulo tiene
lógica escondida, y solo se delega lo que sabrías escribir.

Dato concreto para ese momento, verificado el 2026-08-24 contra la API de la registry:
`terraform-aws-modules/vpc/aws` (v6.7.0) tiene **236 entradas** en su módulo raíz, y
`terraform-aws-modules/iam/aws` → `modules/iam-user` trae **`create_access_key = true` por
defecto**. Ese default habría creado exactamente la clave permanente que la lección 04 evitó a
propósito. Es el mejor ejemplo posible de «lógica escondida que no te enteras».

## El hueco real que reveló: no sabe descubrir valores válidos

Descubrió por su cuenta la limitación: el editor autocompleta `budget_type` como `string`
obligatorio pero no ofrece `COST`. **No es un fallo de la extensión.** Comprobado ejecutando
`terraform providers schema -json` contra su propio provider 6.61.0: el esquema solo lleva
`{"type":"string","required":true}`. Los valores permitidos viven en código dentro del binario
y no se transmiten por el protocolo.

La respuesta que se le dio, y que hay que reutilizar como técnica de enseñanza:
**escribir mal a propósito y ejecutar `terraform validate`.** El provider enumera los valores
válidos en el error, sin credenciales y sin tocar AWS. Verificado:

```
Error: expected budget_type to be one of ["USAGE" "COST" "RI_UTILIZATION"
"RI_COVERAGE" "SAVINGS_PLANS_UTILIZATION" "SAVINGS_PLANS_COVERAGE"], got MONEY
```

**Precedente de enseñanza:** cuando pregunte «¿qué valores acepta X?», no darle la respuesta.
Darle el comando. Es un bucle de retroalimentación que puede cerrar solo, y eso vale más que
cualquier lista que yo le pase.

Se añadió a `reference/terraform-cli.html` una sección nueva —«Cuando no sabes qué valores
acepta un argumento»— con las cuatro vías: `validate` con valor inventado, `providers schema
-json`, la doc en crudo de GitHub, y la referencia de autorización de servicio de AWS para los
nombres de acciones IAM.

## Matiz sobre `data` que no estaba dicho en ninguna parte

Su definición era correcta —«un recurso que existe sin crearlo»— pero le faltaba lo
interesante: **no todos los data sources consultan AWS.**
`aws_iam_policy_document` y `archive_file` no llaman a ninguna API: son funciones locales
disfrazadas de data source porque HCL no tenía forma de expresar «función». Regla práctica que
se le dio: si no necesita credenciales, es de estos.

Añadido a la tarjeta de `data` en la chuleta.

## Lo que no se hizo

No se tocó la lección 04. Él mismo lo pidió —*«no tienes que editar el archivo de 004 porque
no tiene nada que ver»*— y tiene razón: son preguntas transversales, y su sitio es la
referencia que se reconsulta, no una lección que se lee una vez.
