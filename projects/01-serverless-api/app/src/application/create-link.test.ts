import { describe, it } from "node:test";
import assert from "node:assert/strict"
import { z } from "zod";
import { createLink } from "./create-link.ts";
import { InvalidTargetUrlError } from "../domain/errors.ts";


describe("createLink", () => {
    it("returns a 7 characters code", () => {
        assert.match(createLink({ url: "https://www.google.com" }).code, /^[A-Za-z0-9_-]{7}$/);
    })

    // A malformed payload belongs to the use case, not to the domain.
    for (const bad of [{}, { url: 42 }, { url: null }, null, "not an object"]) {
        it(`rechaza el payload ${JSON.stringify(bad)}`, () => {
            assert.throws(() => createLink(bad), z.ZodError);
        });
    }

    // The rule still belongs to the domain, and propagates untouched.
    it("propagates the domain error", () => {
        assert.throws(() => createLink({ url: "ftp://a.dev" }), InvalidTargetUrlError);
    })
})
