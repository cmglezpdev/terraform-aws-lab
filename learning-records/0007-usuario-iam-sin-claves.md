# La identidad de Terraform es un usuario IAM sin claves de acceso, no un rol ni Identity Center

Decisión de diseño de la lección 04 (2026-08-24), tomada contra la recomendación literal de
AWS y por tanto necesaria de justificar.

## Lo que recomienda AWS y lo que hacemos

La primera práctica recomendada de IAM es *«Require human users to use federation with an
identity provider to access AWS using temporary credentials»*, y propone **IAM Identity
Center**. La lección crea un **usuario IAM**.

El motivo por el que esto no es una mala práctica encubierta: el usuario **no tiene ninguna
clave de acceso**. Se entra con `aws login`, que intercambia las credenciales de consola por
credenciales temporales que se refrescan solas y caducan a las 12 horas como máximo. Se
cumple la parte que importa —credenciales temporales en el disco del usuario— y se deja fuera
solo la federación, que en una cuenta suelta sin Organizations no aporta nada.

Descartado explícitamente: `aws_iam_access_key`. Habría metido un `AKIA…` permanente en el
state y en el disco, que es justo lo que las tres primeras prácticas recomendadas intentan
evitar.

## Hallazgo operativo: `SignInLocalDevelopmentAccess`

`aws login` con un usuario IAM **no funciona sin la política gestionada
`arn:aws:iam::aws:policy/SignInLocalDevelopmentAccess`** (creada el 2025-11-19). Root no la
necesita porque root no necesita ninguna política. Está documentado como prerrequisito en
la guía de la CLI, no en la de IAM, así que es fácil no encontrarlo.

Sin ella el login falla y el error no señala de forma evidente que falta esa política. Va
adjunta desde el primer `apply` de la lección precisamente para que el fallo del día sea el
otro, el del bloqueo del state, y no este.

## La estructura de perfiles cambia de significado

A partir de esta lección:

- **`personal`** = usuario IAM `terraform`. Es la identidad de trabajo por defecto, y es lo
  que significa `AWS_PROFILE=personal` en todas las lecciones anteriores y posteriores.
- **`personal-root`** = root. Vía de escape, se prueba antes de necesitarla y se cierra con
  `aws logout` al terminar.

Se eligió mantener el nombre `personal` para la identidad de trabajo en vez de crear un
perfil nuevo, para que los comandos de las lecciones 01–03 sigan siendo correctos tal y como
están escritos. El precio es que `aws login --profile personal` pregunta si se quiere
sobrescribir la sesión de root; la lección avisa de esa pregunta y de que hay que responder
que sí.

## La política es deliberadamente no least-privilege, y se dice

`iam:*` sobre `*` permite que el usuario se adjudique `AdministratorAccess`. Está ahí porque
el mismo módulo raíz gestiona sus propios recursos IAM: cada `plan` tiene que leerlos y cada
`apply`, modificarlos.

La lección lo dice abiertamente en lugar de fingir least privilege, y nombra la alternativa
correcta —identidad humana que administra + rol acotado que ejecuta Terraform— como el
contenido del proyecto 07. Sigue el principio de [LR-0003](./0003-el-apply-no-es-la-prueba.md):
decir siempre qué cubre una prueba y qué no.

## Efecto colateral que había que preservar

El proyecto 00 queda cerrado con esta lección. El [ROADMAP](../ROADMAP.md) le asignaba IAM,
Budgets, SNS y S3, y ya están los cuatro.
