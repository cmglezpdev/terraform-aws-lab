import { randomBytes } from "crypto";

/** 5 bytes = 40 bits = 7 caracteres en base64url, sin relleno. */
const CODE_BYTES = 5;

export interface CreateLinkEvent {
  url: string;
}

export interface CreateLinkResult {
  code: string;
  url: string;
}

function generateCode(): string {
    return randomBytes(CODE_BYTES).toString("base64url");
}

function parseTargetUrl(raw: string | undefined): URL {
    if (typeof raw !== "string" || raw.trim() === "") {
        throw new Error("URL is required")
    }

    let parsed: URL;
    try {
        parsed = new URL(raw);
    } catch (error) {
        throw new Error(`${raw} is not a valid URL`)
    }

  if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
    throw new Error(`Protocolo no admitido: '${parsed.protocol}'`);
  }

  return parsed;
}

export const handler = async (event: CreateLinkEvent): Promise<CreateLinkResult> => {
    const target = parseTargetUrl(event.url);
    const code = generateCode();

    // JSON en una línea: CloudWatch Logs Insights sabe consultarlo.
    console.log(JSON.stringify({ msg: "link created", code, target: target.href }));

    return {
        code,
        url: target.toString(),
    }
}