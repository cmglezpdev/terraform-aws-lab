# 01 · Serverless API — acortador de URLs

Un acortador de URLs completo: `POST /links` crea un enlace corto, `GET /{code}` redirige
al original. Se construye en tres sesiones, y cada una añade una pieza que funciona y se
verifica por su cuenta.

## Qué construye

| Pieza | Qué hace | Servicios | Lección |
|---|---|---|---|
| **El cerebro** | Valida la URL y genera un código corto sin sesgo | Lambda, CloudWatch Logs, IAM | [05](../../lessons/0005-tu-codigo-en-aws.html) |
| **El artefacto** | Capas, `zod` en la frontera, y tests sin dependencias | — (Node, esbuild) | [06](../../lessons/0006-el-zip-no-es-tu-repositorio.html) |
| La memoria | Guarda `código → URL` y resuelve las colisiones | DynamoDB | 07 _(pendiente)_ |
| La puerta | Convierte todo esto en HTTP público | API Gateway HTTP | 08 _(pendiente)_ |

## Coste

**0,00 USD en reposo.** Una función Lambda desplegada y no invocada no factura, un rol de
IAM no factura nunca, y el grupo de logs está muy por debajo de los 5 GB gratuitos mensuales
de CloudWatch. Por eso este proyecto es el primero que se puede dejar desplegado entre
sesiones sin cronómetro.

Precios verificados el 2026-08-24 en `us-east-1` contra la Price List API pública. Los
números completos están en la [ficha de Lambda](../../reference/aws-lambda.html).

## Decisiones de diseño

**El build vive fuera de Terraform.** `esbuild` produce `app/dist/index.mjs` y solo entonces
`archive_file` lo comprime. Terraform gestiona infraestructura; construir artefactos es
trabajo del pipeline. La consecuencia práctica: el orden es siempre `pnpm run build` →
`terraform plan` → `terraform apply`, porque el `data "archive_file"` se resuelve durante el
`plan` y falla si `dist/` no existe.

**`arm64`, no `x86_64`.** Graviton cuesta exactamente un 20% menos por GB-segundo
(`0,0000133334` frente a `0,0000166667` USD). El bundle es JavaScript puro, así que no hay
ningún binario nativo que ate la función a una arquitectura. El provider usa `x86_64` por
defecto: hay que pedirlo explícitamente.

**El grupo de logs se declara, no se hereda.** Si nadie lo crea, Lambda lo crea en la primera
invocación — y entonces no pertenece a Terraform: sobrevive al `destroy`, nace sin retención
y acumula coste para siempre. Declararlo cuesta cuatro líneas y da además el
`retention_in_days`.

**El nombre de la función vive en un `local`.** El grupo de logs necesita el nombre de la
función para componer el suyo (`/aws/lambda/<nombre>`). Referenciar el recurso crearía un
ciclo, porque la función depende del grupo vía `depends_on`. Un `local` es un valor conocido
antes de hablar con AWS: los dos lo leen y ninguno depende del otro.

**El rol de ejecución no lleva `AWSLambdaBasicExecutionRole`.** Esa política gestionada
concede `CreateLogGroup`, `CreateLogStream` y `PutLogEvents` sobre `"*"`. Como el grupo lo
crea Terraform, la función no necesita crear nada: dos acciones sobre un único ARN bastan.
Ese ARN lleva sufijo `:*` porque `PutLogEvents` actúa sobre los *streams*, no sobre el grupo,
y el provider elimina ese sufijo del atributo `.arn` a propósito.

**pnpm, no npm, y el gestor declarado en el `package.json`.** El campo `packageManager`
fija la versión exacta y corepack la respeta: la herramienta se declara, no se supone — la
misma idea que `required_version` en Terraform. Lo que aporta pnpm aquí no es la velocidad
sino que **bloquea por defecto los scripts `postinstall` de las dependencias**, el vector de
los ataques a la cadena de suministro de npm. esbuild necesita el suyo para descargar su
binario nativo, así que se aprueba explícitamente en `app/pnpm-workspace.yaml`:

```yaml
allowBuilds:
  esbuild: true
```

En pnpm 11 la clave es `allowBuilds` y vive en `pnpm-workspace.yaml`, aunque no haya
workspaces. Casi todo el material que circula dice `onlyBuiltDependencies` dentro del
`package.json`: está desfasado.

El `node_modules` de enlaces simbólicos de pnpm no da ningún problema aquí porque lo que se
despliega es el bundle de esbuild, un fichero autocontenido. `node_modules` nunca sale de la
máquina.

**ESM y extensión `.mjs`, no CommonJS.** El `tsc --init` de TypeScript 7 genera
`module: "nodenext"` con `verbatimModuleSyntax`, y esa combinación prohíbe `import` en un
paquete `"type": "commonjs"`. Lambda además recomienda ES modules por el *top-level await*.
La extensión importa: el `.zip` contiene **solo** `dist/`, sin `package.json` dentro, así que
un `index.js` con `import` se ejecutaría como CommonJS y reventaría con *«Cannot use import
statement outside a module»*. Un `.mjs` es siempre ESM, no dependa de nada. El `handler` de
Lambda sigue siendo `index.handler`: AWS resuelve tanto `index.js` como `index.mjs`.

**`@types/node` va en 24, no en la última.** Los tipos describen las APIs disponibles donde el
código se ejecuta, y ahí Node es la 24 porque el runtime es `nodejs24.x`. `nodejs26.x` existe
en Lambda pero está en vista previa pública, sin SLA: Lambda solo publica runtimes estables
cuando la versión entra en LTS activo. Node 24 tiene soporte hasta el 30 de abril de 2028.

**El código de la Lambda está en capas, y la regla para decidir dónde va cada fichero es
«¿esto seguiría siendo cierto en mi portátil?».** `domain/` no importa **nada** que aparezca en
el `package.json` —ni `zod`, ni un ORM, ni un cliente HTTP—; sí puede usar globales del lenguaje
como `URL` o `node:crypto`, porque no se instalan. `application/` orquesta y valida la forma de
lo que entra. `handler.ts` es el único que sabe que esto es una Lambda, y `index.ts` tiene una
línea, porque el `handler = "index.handler"` de AWS no debe dictar cómo se organiza el código.

La razón no es estética, y la escribe AWS en la primera de sus buenas prácticas para TypeScript:
*«Separate the Lambda handler from your core logic. This allows you to make a more unit-testable
function.»* Leída al revés es una prueba de diagnóstico: **si para probar una función necesitas
AWS, es que la función sabe demasiado sobre AWS.**

**La regla vive en el dominio; el mecanismo de validación, fuera.** `ALLOWED_PROTOCOLS` y
`MAX_URL_LENGTH` son del negocio y se exportan como datos. El esquema de `zod` que comprueba la
*forma* del payload —«¿es un objeto con un campo `url` de tipo cadena?»— vive en el caso de uso,
porque eso es un contrato de transporte, no una regla. La prueba de que la separación es
correcta: **cambiar `zod` por Valibot no toca `domain/`.**

Efecto secundario que confirma la frontera: los tests se reparten solos. `{ url: 42 }` y `null`
caen en `create-link.test.ts`; `"javascript:alert(1)"` y `"ftp://…"` en `target-url.test.ts`.
Cuando un caso de prueba no sabe a qué fichero pertenece, la frontera está mal puesta.

**Tests con cero dependencias.** Node 24 ejecuta TypeScript directamente borrándole los tipos, y
trae ejecutor de tests: `node --test 'src/**/*.test.ts'`. No hay Jest ni Vitest. El precio es que
Node no compila, solo borra, así que la sintaxis que exige *generar* código está prohibida:
`constructor(readonly x: string)` revienta con
`ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX: TypeScript parameter property is not supported in strip-only
mode`. Lo mismo con `enum` y `namespace`. Hace falta `allowImportingTsExtensions: true` en el
`tsconfig.json`, que TypeScript solo permite con `noEmit`.

**El `archive_file` comprime un fichero, no el directorio.** Con `source_dir` el `.zip` se llevaba
también `dist/index.mjs.map`, que Node no lee salvo que arranques con `--enable-source-maps`. Con
`zod` dentro ese sourcemap pasa a pesar casi un mega —el 75% del paquete— así que se pasó a
`source_file = "${path.module}/app/dist/index.mjs"`. El zip baja de 220 KB a 65 KB, y el
`handler = "index.handler"` sigue valiendo porque `archive_file` usa el *basename*. Con varias
funciones, un `archive_file` por función.

**`zod` se empaqueta en el bundle; no se usa una *layer*.** Una layer para una dependencia
JavaScript pura da lo peor de los dos mundos: tu código y sus dependencias dejan de versionarse
juntos y se pierde el *tree shaking*, porque se sube el paquete completo. Las layers resuelven
otro problema —compartir binarios pesados entre muchas funciones, o fijar la versión del SDK
embebido—. Para poner en contexto el tamaño: siete dependencias típicas de una API dan un
`node_modules` de 58 MB y 10 218 ficheros, y un bundle de 1 076 KB —el 0,6% del límite de 50 MB
del `.zip`—.

**El código corto es `base64url`, no un alfabeto «legible».** Un alfabeto de 56 símbolos con
`byte % 56` está sesgado, porque 256 no es múltiplo de 56. `base64url` tiene 64 símbolos y
256 sí lo es: 5 bytes dan 7 caracteres sin sesgo y sin relleno, sobre un espacio de 64⁷ ≈ 4,4
billones. Las colisiones no desaparecen —al 50% con ~2,5 millones de enlaces— y se resuelven
donde toca: con una escritura condicional en DynamoDB, en la lección 07.

**Solo `http:` y `https:`.** Rechazar `javascript:`, `data:` y `file:` es una decisión de
seguridad, no de validación: sin ella, el acortador serviría enlaces de un tercero bajo tu
propio dominio.

## Uso

```bash
export AWS_PROFILE=personal
aws login
aws sts get-caller-identity     # el Arn debe terminar en ":user/terraform"

cd app && pnpm install && pnpm run typecheck && pnpm run test && pnpm run build && cd ..

terraform init
terraform plan
terraform apply

FN=$(terraform output -raw function_name)
aws lambda invoke \
  --function-name "$FN" \
  --cli-binary-format raw-in-base64-out \
  --payload '{"url":"https://developer.hashicorp.com/terraform"}' \
  respuesta.json && cat respuesta.json

aws logs tail "$(terraform output -raw log_group_name)" --since 10m
```

`terraform destroy` es limpio y no toca nada del proyecto 00. Para volver a levantarlo:
`pnpm run build && terraform apply`.

## Requisitos previos

El proyecto [00-foundations](../00-foundations/) debe estar aplicado, y la política del
usuario `terraform` necesita `lambda:*`, `logs:*` y permiso sobre la clave de state
`01-serverless-api/terraform.tfstate`. La lección 05 lo amplía.

## Cadena de herramientas

Verificada el 2026-08-24 contra el registro de npm.

| Herramienta | Versión | Por qué esa |
|---|---|---|
| Runtime Lambda | `nodejs24.x` | LTS activo, soporte hasta 30 abr 2028. La 26 está en vista previa |
| pnpm | `11.23.0` | Fijada en `packageManager`; corepack la respeta |
| TypeScript | `^7.0.2` | Compilador nativo. Solo comprueba: emitir es de esbuild |
| esbuild | `^0.28.2` | Empaqueta y transpila. **No comprueba tipos** |
| `@types/node` | `^24.13.3` | Debe coincidir con el runtime, no con tu portátil |
| `zod` | `^4.4.3` | **`dependencies`**, no `devDependencies`: se ejecuta en producción |
| Tests | `node --test` | Del propio runtime. Cero dependencias de testing |

Se versionan `pnpm-lock.yaml` y `pnpm-workspace.yaml`. El lockfile es el equivalente de
`.terraform.lock.hcl`. Se ignoran `app/node_modules/`, `app/dist/` y `build/`.
