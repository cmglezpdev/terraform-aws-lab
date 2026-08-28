import { describe, it } from "node:test";
import assert from "node:assert/strict"
import { parseTargetUrl } from "./target-url.ts";
import { InvalidTargetUrlError } from "./errors.ts";



describe("parseTargetUrl", () => {
    it("normalize the url", () => {
        assert.equal(parseTargetUrl("https://www.google.com"), "https://www.google.com/");
    })

    for (const bad of ["javascript:alert(1)", "ftp://a.dev", "", "no-soy-url"]) {
        it(`rechaza ${JSON.stringify(bad)}`, () => {
            assert.throws(() => parseTargetUrl(bad), InvalidTargetUrlError);
          });
    }
})