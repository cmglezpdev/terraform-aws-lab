import { isShortCode } from "../domain/short-code.ts";
import type { TargetUrl } from "../domain/target-url.ts";
import type { LinkFinder } from "./link-finder.ts";


export async function getLink(rawCode: string, finder: LinkFinder): Promise<TargetUrl | null> {
    if(!isShortCode(rawCode)) return null;

    const link = await finder.findByCode(rawCode);
    return link?.url ?? null;
}