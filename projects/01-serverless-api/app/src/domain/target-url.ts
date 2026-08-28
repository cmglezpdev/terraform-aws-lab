import { InvalidTargetUrlError } from "./errors.ts";

/** The business rule, as plain data. Nobody outside decides this. */
export const ALLOWED_PROTOCOLS = ["http:", "https:"] as const;
export const MAX_URL_LENGTH = 2048;

export type TargetUrl = string & { readonly __brand: "TargetUrl" };

/** URL is a language global, not a dependency: it can live in the domain. */
export function parseTargetUrl(raw: string): TargetUrl {
    if (raw.length > MAX_URL_LENGTH) {
        throw new InvalidTargetUrlError(`URL is too long. Max length is ${MAX_URL_LENGTH} characters`);
    }

    let parsed: URL;
    try {
        parsed = new URL(raw);
    } catch {
        throw new InvalidTargetUrlError("Not a valid URL");
    }

    if (!ALLOWED_PROTOCOLS.includes(parsed.protocol as (typeof ALLOWED_PROTOCOLS)[number])) {
        throw new InvalidTargetUrlError("Just is supported http and https URLs");
    }

    return parsed.href as TargetUrl; // .href normalizes: adds the trailing slash
}
