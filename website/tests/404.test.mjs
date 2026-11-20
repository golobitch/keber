import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

// Cloudflare serves the nearest 404.html for assets.not_found_handling = "404-page":
// https://developers.cloudflare.com/workers/static-assets/routing/static-site-generation/
test("the built 404 page has a home link and is enabled in Wrangler", async () => {
  const html = await readFile(new URL("../dist/404.html", import.meta.url), "utf8");
  const config = await readFile(new URL("../wrangler.jsonc", import.meta.url), "utf8");
  assert.match(html, /<h1[^>]*>\s*404 · Page not found<\/h1>/);
  assert.match(html, /<a\b[^>]*href="\/(?:[^"/]+\/)*"[^>]*>(?:(?!<\/a>)[\s\S])*Back to home/);
  assert.match(config, /"not_found_handling"\s*:\s*"404-page"/);
});
