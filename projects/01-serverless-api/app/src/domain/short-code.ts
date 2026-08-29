import { randomBytes } from "node:crypto";

const CODE_BYTES = 5;
const CODE_SHAPE = /^[A-Za-z0-9_-]{7}$/;

export type ShortCode = string & { readonly __brand: "ShortCode" };

export function generateShortCode(): ShortCode {
    return randomBytes(CODE_BYTES).toString("base64url") as ShortCode;
}

export function isShortCode(raw: string): raw is ShortCode {
    return CODE_SHAPE.test(raw);
}