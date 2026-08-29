import type { Link } from "../domain/link.ts";

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