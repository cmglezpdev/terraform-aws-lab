import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { z } from "zod";
import { createLink } from "./create-link.ts";
import { CodeCollisionError, type LinkRepository } from "./link-repository.ts";
import { InvalidTargetUrlError } from "../domain/errors.ts";
import type { Link } from "../domain/link.ts";

/** Fake en memoria: mismo contrato, cero AWS. `collisions` hace fallar los N primeros saves. */
class FakeLinkRepository implements LinkRepository {
  saved: Link[] = [];
  attempted: Link[] = [];
  private collisions: number;

  constructor(collisions = 0) {
    this.collisions = collisions;
  }

  async save(link: Link): Promise<void> {
    this.attempted.push(link);
    if (this.collisions > 0) {
      this.collisions--;
      throw new CodeCollisionError(link.code);
    }
    this.saved.push(link);
  }
}

describe("createLink", () => {
  it("saves the link and returns a 7 characters code", async () => {
    const repository = new FakeLinkRepository();
    const link = await createLink({ url: "https://www.google.com" }, repository);
    assert.match(link.code, /^[A-Za-z0-9_-]{7}$/);
    assert.deepEqual(repository.saved, [link]);
  });

  // La forma del payload pertenece al caso de uso, no al dominio.
  for (const bad of [{}, { url: 42 }, { url: null }, null, "not an object"]) {
    it(`rechaza el payload ${JSON.stringify(bad)}`, async () => {
      await assert.rejects(() => createLink(bad, new FakeLinkRepository()), z.ZodError);
    });
  }

  it("propagates the domain error without touching the repository", async () => {
    const repository = new FakeLinkRepository();
    await assert.rejects(() => createLink({ url: "ftp://a.dev" }, repository), InvalidTargetUrlError);
    assert.equal(repository.attempted.length, 0);
  });

  it("retries a collision with a new code and the same url", async () => {
    const repository = new FakeLinkRepository(1);
    const link = await createLink({ url: "https://www.google.com" }, repository);
    assert.equal(repository.attempted.length, 2);
    assert.notEqual(repository.attempted[0]!.code, repository.attempted[1]!.code);
    assert.equal(repository.attempted[0]!.url, repository.attempted[1]!.url);
    assert.deepEqual(repository.saved, [link]);
  });

  it("gives up after three collisions and saves nothing", async () => {
    const repository = new FakeLinkRepository(Infinity);
    await assert.rejects(
      () => createLink({ url: "https://www.google.com" }, repository),
      CodeCollisionError,
    );
    assert.equal(repository.attempted.length, 3);
    assert.equal(repository.saved.length, 0);
  });
});