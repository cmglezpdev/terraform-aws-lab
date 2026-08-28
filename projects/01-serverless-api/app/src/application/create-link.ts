import { z } from "zod";
import { generateShortCode, type ShortCode } from "../domain/short-code.ts";
import { parseTargetUrl, MAX_URL_LENGTH, type TargetUrl } from "../domain/target-url.ts";
import { CodeCollisionError, type LinkRepository } from "./link-repository.ts";

const MAX_ATTEMPTS = 3;

/** The payload shape: a transport contract, not a business rule. */
const createLinkInput = z.object({
    url: z.string().max(MAX_URL_LENGTH),
});

export interface Link {
    code: ShortCode;
    url: TargetUrl;
}

export async function createLink(payload: unknown, repository: LinkRepository): Promise<Link> {
    const { url } = createLinkInput.parse(payload);
    const target = parseTargetUrl(url);

    let lastCollision: CodeCollisionError | undefined;
    for(let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
        const link: Link = {
            code: generateShortCode(),
            url: target,
        }
        try {
            await repository.save(link)
            return link;
        } catch(error) {
            if(!(error instanceof CodeCollisionError)) throw error;
            lastCollision = error;
        }
    }

    throw lastCollision;
}
