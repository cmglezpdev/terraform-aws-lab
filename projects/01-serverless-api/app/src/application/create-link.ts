import { z } from "zod";
import { generateShortCode, type ShortCode } from "../domain/short-code.ts";
import { parseTargetUrl, MAX_URL_LENGTH } from "../domain/target-url.ts";

/** The payload shape: a transport contract, not a business rule. */
const createLinkInput = z.object({
    url: z.string().max(MAX_URL_LENGTH),
});

export interface Link {
    code: ShortCode;
    url: string;
}

export function createLink(payload: unknown): Link {
    const { url } = createLinkInput.parse(payload);
    return {
        code: generateShortCode(),
        url: parseTargetUrl(url)
    }
}
