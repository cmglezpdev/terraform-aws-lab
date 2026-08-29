// Humo de los dos bundles ESM. Regla de la lección 07: siempre desde un .mjs.
process.env.TABLE_NAME = "smoke-table";

const { handler: createLink } = await import("./dist/create-link.mjs");
const { handler: getLink } = await import("./dist/get-link.mjs");

let failures = 0;
const expect = async (label, promise, statusCode) => {
  const res = await promise;
  const ok = res.statusCode === statusCode;
  if (!ok) failures++;
  console.log(`${ok ? "ok " : "FAIL"} ${label} → ${res.statusCode} (esperaba ${statusCode})`);
};

const post = (body) => createLink({ version: "2.0", routeKey: "POST /links", body });
const get = (code) => getLink({ version: "2.0", routeKey: "GET /{code}", pathParameters: { code } });

// Los tres 400 de create-link: ninguno necesita AWS.
await expect("body no-JSON        ", post("esto no es json"), 400);
await expect("payload sin url     ", post(JSON.stringify({ enlace: "https://x.com" })), 400);
await expect("protocolo prohibido ", post(JSON.stringify({ url: "ftp://archivo.viejo" })), 400);

// Los 404 baratos de get-link: la guarda responde sin tocar la tabla.
await expect("favicon.ico         ", get("favicon.ico"), 404);
await expect("código corto        ", get("x"), 404);
await expect("sin pathParameters  ", getLink({ version: "2.0" }), 404);

process.exit(failures ? 1 : 0);