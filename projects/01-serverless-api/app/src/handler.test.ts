import { describe, it, mock } from "node:test";
import assert from "node:assert/strict";
import { handler } from "./handler.ts";
import { InvalidTargetUrlError } from "./domain/errors.ts";

describe("handler", () => {
  it("returns a 7 characters code", async () => {
    mock.method(console, "log", () => {});          // silencia el log
    const link = await handler({ url: "https://developer.hashicorp.com" });
    assert.match(link.code, /^[A-Za-z0-9_-]{7}$/);
    assert.equal(link.url, "https://developer.hashicorp.com/");
  });

  it("propagates the domain error", async () => {
    mock.method(console, "error", () => {});   // el rechazo va por console.error
    await assert.rejects(() => handler({ url: "ftp://a.dev" }), InvalidTargetUrlError);
  });
});