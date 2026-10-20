"use strict";

const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");

const root = path.join(__dirname, "..");
const render = fs.readFileSync(path.join(root, "render.yaml"), "utf8");
const envExample = fs.readFileSync(path.join(root, ".env.example"), "utf8");

test("Render serves from main with the liveness endpoint and normal Node commands", () => {
  assert.match(render, /^\s*branch:\s*main\s*$/m);
  assert.match(render, /^\s*buildCommand:\s*npm install\s*$/m);
  assert.match(render, /^\s*startCommand:\s*npm start\s*$/m);
  assert.match(render, /^\s*healthCheckPath:\s*\/healthz\s*$/m);
});

test("public deployment keeps demo transfers disabled and database URL secret-managed", () => {
  const transferBlock = render.match(/-\s*key:\s*ENABLE_DEMO_TRANSFERS\s*\n\s*value:\s*["']?(false|true)["']?/i);
  assert.ok(transferBlock, "Render must declare the transfer safety flag");
  assert.equal(transferBlock[1].toLowerCase(), "false", "public Render deployments must fail closed");
  assert.match(render, /-\s*key:\s*MYSQL_URL\s*\n\s*sync:\s*false/i,
    "the database URL must be configured as a secret rather than committed");

  const exampleFlag = envExample.match(/^ENABLE_DEMO_TRANSFERS=(.*)$/m);
  assert.ok(exampleFlag, ".env.example must state the transfer default");
  assert.equal(exampleFlag[1].trim().toLowerCase(), "false");
});
