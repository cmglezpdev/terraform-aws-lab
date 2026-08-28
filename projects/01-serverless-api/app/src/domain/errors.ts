
export class InvalidTargetUrlError extends Error {
    readonly reason: string;

    constructor(reason: string) {
        super(reason);
        this.name = "InvalidTargetUrlError";
        this.reason = reason;
    }
}