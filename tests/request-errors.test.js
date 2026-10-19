const { spawn } = require("node:child_process");
const net = require("node:net");
const path = require("node:path");
const { after, before, test } = require("node:test");
const assert = require("node:assert/strict");

let child;
let baseUrl;

async function availablePort() {
  const server = net.createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  const port = server.address().port;
  await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  return port;
}

before(async () => {
  const port = await availablePort();
  baseUrl = `http://127.0.0.1:${port}`;
  const env = { ...process.env, PORT: String(port), ENABLE_DEMO_TRANSFERS: "false" };
  for (const key of Object.keys(env)) if (key.startsWith("MYSQL_")) delete env[key];
  child = spawn(process.execPath, [path.join(__dirname, "..", "server.js")], { env, stdio: "ignore" });
  for (let attempt = 0; attempt < 60; attempt += 1) {
    if (child.exitCode !== null) throw new Error("Server exited before becoming ready");
    try {
      if ((await fetch(baseUrl + "/healthz")).ok) return;
    } catch (_) {}
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  throw new Error("Server did not become ready");
});

after(() => {
  if (child && child.exitCode === null) child.kill("SIGTERM");
});

test("malformed JSON is rejected as a client error without caching", async () => {
  const response = await fetch(baseUrl + "/api/transfers", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: "{invalid-json"
  });
  assert.equal(response.status, 400);
  assert.equal(response.headers.get("cache-control"), "no-store");
  assert.match((await response.json()).error, /valid JSON/i);
});

test("JSON larger than the documented limit returns 413 without caching", async () => {
  const response = await fetch(baseUrl + "/api/transfers", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ payload: "x".repeat(21 * 1024) })
  });
  assert.equal(response.status, 413);
  assert.equal(response.headers.get("cache-control"), "no-store");
  assert.match((await response.json()).error, /20 KB/i);
});
