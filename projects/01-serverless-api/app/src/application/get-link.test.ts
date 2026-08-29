import { describe, it } from "node:test";
import type { LinkFinder } from "./link-finder.ts";
import type { Link } from "../domain/link.ts";
import { generateShortCode, type ShortCode } from "../domain/short-code.ts";
import type { TargetUrl } from "../domain/target-url.ts";
import { getLink } from "./get-link.ts";
import assert from "node:assert/strict";

class FakeLinkFinder implements LinkFinder {
    lookups: string[] = [];
    private readonly links: Map<string, Link> = new Map();
    
    constructor(links: Link[] = []) {
        this.links = new Map(links.map((link) => [link.code, link]));
    }

    findByCode(code: ShortCode): Promise<Link | null> {
        this.lookups.push(code);
        return Promise.resolve(this.links.get(code) ?? null);
    }
}


describe("getLink", () => {
    const code = generateShortCode();
    const url = "https://www.google.com" as TargetUrl;

    it("returns the target URL when the code exists", async () => {
        const finder = new FakeLinkFinder([{ code, url }]);
        const result = await getLink(code, finder);
        assert.equal(result, url);
    })

    it("returns null when the code has valid shape but is not stored", async () => {
        const finder = new FakeLinkFinder();
        assert.equal(await getLink(generateShortCode(), finder), null);
        assert.equal(finder.lookups.length, 1);
      });
    
      // Lo que un curl no puede demostrar: que el 404 barato no tocó la tabla.
      for (const junk of ["favicon.ico", "robots.txt", "x", "toolong99", "abc/def", ""]) {
        it(`rejects "${junk}" without asking the finder`, async () => {
          const finder = new FakeLinkFinder();
          assert.equal(await getLink(junk, finder), null);
          assert.equal(finder.lookups.length, 0);
        });
      }
})