import { randomBytes } from "node:crypto";

const CODE_BYTES = 5;

export type ShortCode = string & { readonly __brand: "ShortCode" };

export function generateShortCode(): ShortCode {
    return randomBytes(CODE_BYTES).toString("base64url") as ShortCode;
}