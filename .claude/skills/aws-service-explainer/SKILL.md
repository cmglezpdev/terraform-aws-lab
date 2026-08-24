---
name: aws-service-explainer
description: Escribe explicadores de servicios AWS para el curso de Terraform — una página HTML de referencia autónoma y/o una sección embebida en una lección, que responden qué es el servicio, para qué sirve, qué tipos hay, cómo funciona por dentro, cuánto cuesta, qué límites tiene y cuándo NO usarlo. Úsalo siempre que una lección o un proyecto introduzca un servicio de AWS que el usuario aún no ha estudiado.
---

# Explicadores de servicios AWS

Este workspace enseña **dos cosas a la vez**: Terraform y AWS. El código Terraform enseña
lo primero. Este skill produce lo segundo.

El usuario tiene conocimientos básicos de AWS: reconoce los nombres de los servicios y sabe
aproximadamente para qué son. Lo que le falta es el **detalle operativo** — los tipos, el
modelo de coste, los límites, y sobre todo el criterio de cuándo elegir uno u otro. Un
explicador que solo diga "SQS es una cola de mensajes" es inútil: eso ya lo sabe.

## Las ocho preguntas

Todo explicador responde estas ocho, en este orden, ninguna omitida. Si no puedes responder
alguna con una fuente, dilo explícitamente en el documento en lugar de rellenarla.

1. **Qué es** — en una frase, sin marketing. Qué problema concreto resuelve.
2. **Para qué se usa de verdad** — 3-5 casos de uso reales, no "para desacoplar sistemas"
   sino "para que el pico de un Black Friday no tumbe el servicio de facturación".
3. **Qué tipos/variantes hay** — y el criterio para elegir entre ellos. Esta es la sección
   que más valor aporta y la que casi todos los tutoriales omiten. Tabla comparativa.
4. **Cómo funciona por dentro** — el modelo mental mínimo para no cometer errores:
   garantías de entrega, orden, durabilidad, consistencia, latencia, sincronía.
5. **Cuánto cuesta** — **cifras reales con fecha de verificación**. Qué es gratis, qué se
   paga por uso, y qué se paga por hora esté o no en uso (esta distinción es la que
   determina si el usuario puede dejarlo desplegado).
6. **Límites y cuotas** — los números que va a chocar de verdad, con si son ajustables.
7. **Cuándo NO usarlo** — con qué servicio se confunde y cuál es el criterio de decisión.
   Un explicador sin esta sección está incompleto.
8. **Cómo se ve en Terraform** — los recursos principales del provider AWS, con los
   argumentos obligatorios y las trampas conocidas.

## Regla no negociable: verificar

**Nunca escribas un explicador desde conocimiento paramétrico.** Precios, límites y tipos
cambian, y un dato inventado destruye la confianza en todo el curso.

Antes de escribir, consulta y cita:

- `https://docs.aws.amazon.com/<servicio>/latest/dg/` — la guía del desarrollador
- `https://aws.amazon.com/<servicio>/pricing/` — precios (anota la **fecha** y la **región**;
  usa `us-east-1` salvo que el proyecto use otra)
- `https://docs.aws.amazon.com/general/latest/gr/<servicio>.html` — cuotas del servicio
- `https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/main/website/docs/r/<recurso>.html.markdown`
  — el esquema real del recurso Terraform (la web del registry es una SPA y no se puede
  leer con WebFetch; usa siempre el markdown crudo de GitHub)

Cada afirmación numérica del documento lleva enlace a su fuente. Los precios llevan una
línea de "verificado el AAAA-MM-DD en la región X".

Cuando una fuente contradiga lo que creías saber, gana la fuente — y si la contradicción
afecta a algo que ya se enseñó en una lección anterior, **corrige esa lección también**.

## Dónde va cada cosa

| Formato | Ruta | Cuándo |
|---|---|---|
| Referencia autónoma | `reference/aws-<servicio>.html` | Siempre que el servicio se use en un proyecto. Es lo que el usuario reconsulta. |
| Sección embebida | dentro de `lessons/NNNN-*.html` | Versión comprimida: preguntas 1, 3 y 5, más un enlace a la referencia completa. |

Nombra el fichero por el servicio, no por la lección: `aws-sqs.html`, `aws-budgets.html`,
`aws-cloudfront.html`. Un servicio, un fichero, aunque aparezca en cuatro proyectos.
Cuando un proyecto posterior use el servicio más a fondo, **amplía el fichero existente**;
no crees un segundo.

## Estructura HTML

Usa siempre `assets/course.css` y `assets/lesson.js`. No inventes estilos: si necesitas un
componente nuevo, añádelo a `course.css` para que las demás páginas lo hereden.

Esqueleto de una referencia autónoma — ver `TEMPLATE.html` en este directorio:

```html
<body class="reference">
  <header>  <!-- eyebrow, h1, deck, .svc-meta --> </header>
  <main>
    <h2>Qué es</h2>                      <!-- + .callout.why con la analogía -->
    <h2>Para qué se usa</h2>             <!-- .ref-grid de casos reales -->
    <h2>Los tipos que existen</h2>       <!-- tabla comparativa + criterio -->
    <h2>Cómo funciona por dentro</h2>    <!-- figure/svg si aporta -->
    <h2>Cuánto cuesta</h2>               <!-- .cost-table + .callout.cost -->
    <h2>Límites que vas a chocar</h2>    <!-- tabla: límite / valor / ajustable -->
    <h2>Cuándo NO usarlo</h2>            <!-- .callout.trap + tabla de confusiones -->
    <h2>En Terraform</h2>                <!-- .code con el recurso principal -->
    <h2>Comprueba</h2>                   <!-- 3-4 .quiz -->
    <div class="next">                   <!-- enlaces + .ask -->
  </main>
</body>
```

Clases disponibles en `course.css`: `.callout` con variantes `why | tf | aws | cost | trap |
win`, `.ref-grid` + `.ref-card`, `.code` + `.code-label`, `.quiz`, `.recall`, `.checklist`,
`.svc-meta`, `.cost-table`, `.verdict`, `.scroll-x`.

## Reglas de las preguntas

Van al final, en bloques `.quiz`, 3-4 por explicador. Prueban **criterio**, no memoria:

- Mal: "¿Cuánto cuesta un NAT Gateway por hora?"
- Bien: "Tu app en subred privada solo necesita llamar a la API de S3. ¿NAT Gateway o VPC
  endpoint?"

Al menos una pregunta debe ser de **coste** y al menos una de **elegir entre variantes**.
Todas las opciones de una pregunta deben tener **el mismo número de palabras**, y una
longitud en caracteres lo más parecida posible: el formato no puede delatar la respuesta.
Cada opción lleva su `data-why`, también las incorrectas — explicar por qué algo está mal
enseña más que confirmar lo correcto.

## Tono

- Español. Términos técnicos e identificadores en inglés.
- Cifras concretas antes que adjetivos. "0,045 USD/h" y no "puede resultar caro".
- Di lo que la documentación de AWS no dice: qué se rompe, qué sorprende en la factura, qué
  confunde a la gente. Esa es la parte que el usuario no puede sacar de la doc oficial.
- Nada de "en este emocionante servicio". Es material de referencia, no un blog.

## Después de escribir

1. Añade el fichero a la tabla de `reference/README.md` (créala si no existe).
2. Añade los términos nuevos a `GLOSSARY.md`, en **Pendientes de promover** hasta que el
   usuario demuestre que los usa bien.
3. Si el explicador contradice algo dicho en una lección anterior, corrige esa lección y
   dilo abiertamente en la respuesta al usuario.
4. Valida el HTML antes de darlo por bueno (balance de etiquetas) y ábrelo con `open`.
