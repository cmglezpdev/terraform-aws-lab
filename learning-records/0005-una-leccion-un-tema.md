# Una lección, un tema: state e IAM se separan

La lección 02 anunciaba que la 03 haría dos cosas: mover el state a S3 **y** crear el usuario
IAM que sustituye a root. Al diseñarla no cabían: son ~40 minutos cada una y la restricción
operativa nº 1 del curso son sesiones de 30-45 minutos que se completan enteras.

La lección 03 se queda solo con el state. IAM pasa a la 04.

## Por qué esta separación y no otra

No es solo cuestión de minutos. Son **dos preguntas distintas** y mezclarlas habría enseñado
peor las dos:

- La 03 responde *dónde vive el state y quién decide quién lo escribe*.
- La 04 responde *qué identidad tiene permiso para tocarlo*.

Y el orden importa en la dirección elegida: con el backend ya montado, quitarse permisos en la
04 se convierte en una **prueba real del backend**. Si la identidad nueva no tiene
`s3:GetObject`, `s3:PutObject` y `s3:DeleteObject` sobre `<key>.tflock`, Terraform deja de
funcionar y el usuario lo descubre por sí mismo. Al revés no se habría podido probar nada.

Eso además da continuidad al principio de [LR-0003](./0003-el-apply-no-es-la-prueba.md): la
lección 03 dice explícitamente que **no** demuestra nada sobre permisos porque sigue entrando
como root, y convierte esa carencia en el gancho de la siguiente.

## Precedente

Cuando una lección anuncie dos temas y no quepan, se separa y **se dice en la propia lección
que se ha separado y por qué**. El usuario está siguiendo un roadmap y necesita ver que el
cambio de plan es deliberado, no un olvido. La lección 03 lleva esa nota al pie.

## Decisión del usuario — resuelta el 2026-08-24

El ID de cuenta `999999999999` aparece ya en `MISSION.md`, en `reference/terraform-cli.html` y
ahora en el `backend.tf` de la lección 03, y el repositorio iba a ser público.

**Decidió sacarlo.** Todos los identificadores de cuenta del repositorio son ahora marcadores
de posición (`999999999999`, `111111111111`), igual que el correo de los ejemplos. El bucket
de state se llama `tf-state-learning-course-terraform`, sin el ID dentro, así que `backend.tf`
no expone nada y no hizo falta recurrir a *partial configuration*.

Precedente: **todo ejemplo de aquí en adelante usa identificadores ficticios.** Lo real vive en
`terraform.tfvars`, que está en `.gitignore`.
