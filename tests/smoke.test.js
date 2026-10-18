const { spawn } = require("node:child_process");
const net = require("node:net");
const path = require("node:path");
const { after, before, test } = require("node:test");
const assert = require("node:assert/strict");

let child;
let baseUrl;
let childOutput = "";

async function findPort() {
  const server = net.createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  const address = server.address();
  await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  return address.port;
}

before(async () => {
  const port = await findPort();
  baseUrl = "http://127.0.0.1:" + port;
  const env = { ...process.env, PORT: String(port), ENABLE_DEMO_TRANSFERS: "false" };
  for (const key of Object.keys(env)) {
    if (key.startsWith("MYSQL_")) delete env[key];
  }

  child = spawn(process.execPath, [path.join(__dirname, "..", "server.js")], {
    env,
    stdio: ["ignore", "pipe", "pipe"]
  });
  child.stdout.on("data", (chunk) => { childOutput += chunk.toString(); });
  child.stderr.on("data", (chunk) => { childOutput += chunk.toString(); });

  let ready = false;
  for (let attempt = 0; attempt < 60; attempt += 1) {
    if (child.exitCode !== null) throw new Error("Server exited early:\n" + childOutput);
    try {
      const response = await fetch(baseUrl + "/healthz");
      if (response.ok) {
        ready = true;
        break;
      }
    } catch (_) {
      // The server may still be starting; retry briefly.
    }
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  if (!ready) throw new Error("Server did not become healthy:\n" + childOutput);
});

after(() => {
  if (child && child.exitCode === null) {
    child.kill("SIGTERM");
  }
});

test("liveness endpoint responds without database credentials", async () => {
  const response = await fetch(baseUrl + "/healthz");
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { ok: true, service: "running" });
});

test("database health clearly reports an unconfigured MySQL connection", async () => {
  const response = await fetch(baseUrl + "/api/health");
  assert.equal(response.status, 503);
  const payload = await response.json();
  assert.equal(payload.ok, false);
  assert.equal(payload.database, "not_configured");
  assert.equal(payload.transfersEnabled, false);
});

test("data endpoints return a clear service-unavailable response without MySQL", async () => {
  const response = await fetch(baseUrl + "/api/overview");
  assert.equal(response.status, 503);
  assert.match((await response.json()).error, /MySQL is not configured/i);
});

test("transfer writes fail closed when no database is configured", async () => {
  const response = await fetch(baseUrl + "/api/transfers", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ fromAccountId: 1, toAccountId: 2, amount: 10 })
  });
  assert.equal(response.status, 503);
  assert.match((await response.json()).error, /MySQL is not configured/i);
});

test("static dashboard assets are served by the API service", async () => {
  const [page, css, js] = await Promise.all([
    fetch(baseUrl + "/"),
    fetch(baseUrl + "/styles.css"),
    fetch(baseUrl + "/app.js")
  ]);
  assert.equal(page.status, 200);
  assert.match(await page.text(), /Ledgerly — Banking Operations/);
  assert.equal(css.status, 200);
  assert.equal(js.status, 200);
});


test("API catalogue is cache-protected and keeps transfer mode explicit", async () => {
  const response = await fetch(baseUrl + "/api");
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("cache-control"), "no-store");
  const payload = await response.json();
  assert.equal(payload.name, "Ledgerly Banking API");
  const transfer = payload.endpoints.find((endpoint) => endpoint.path === "/api/transfers");
  assert.ok(transfer, "transfer endpoint should be documented in the API catalogue");
  assert.match(transfer.description, /disabled/i);
});
