import type { ShortCode } from "../domain/short-code.ts";
import type { TargetUrl } from "../domain/target-url.ts";


export interface Link {
    code: ShortCode;
    url: TargetUrl;
}

export interface LinkRepository {
    save(link: Link): Promise<void>;
}

export class CodeCollisionError extends Error {
    readonly code: string;

    constructor(code: string) {
        super(`Short code already taken: ${code}`);
        this.name = "CodeCollisionError";
        this.code = code;
    }
}