import type { ShortCode } from "./short-code.ts";
import type { TargetUrl } from "./target-url.ts";

export interface Link {
    code: ShortCode;
    url: TargetUrl;
}
