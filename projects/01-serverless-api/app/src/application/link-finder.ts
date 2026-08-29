import type { ShortCode } from "../domain/short-code.ts";
import type { Link } from "../domain/link.ts";

export interface LinkFinder {
    findByCode(code: ShortCode): Promise<Link | null>;
}
