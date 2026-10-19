const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const directory = path.join(__dirname, "..", "advanced_sql");
const sqlFiles = fs.readdirSync(directory).filter((name) => name.endsWith(".sql")).sort();
const numberedFiles = sqlFiles.filter((name) => /^\d{3}_.+\.sql$/.test(name));

test("numbered SQL case studies use a unique, gap-free sequence", () => {
  assert.ok(numberedFiles.length >= 65, "expected the core advanced SQL library");
  assert.equal(new Set(numberedFiles).size, numberedFiles.length, "numbered filenames must be unique");
  for (const [index, name] of numberedFiles.entries()) {
    assert.equal(Number(name.slice(0, 3)), index + 1, `unexpected sequence at ${name}`);
  }
});

test("numbered and supplemental SQL files are non-empty and start with comments", () => {
  assert.ok(sqlFiles.length >= numberedFiles.length, "SQL inventory should include the numbered library");
  for (const name of sqlFiles) {
    const source = fs.readFileSync(path.join(directory, name), "utf8");
    assert.match(source.trimStart(), /^--\s+\S/m, `${name} needs a leading comment`);
    assert.ok(source.trim().length > 80, `${name} looks incomplete`);
  }
});

test("analytical SQL examples avoid obvious data-changing statements", () => {
  const forbidden = /^\s*(DROP|TRUNCATE|DELETE|INSERT|UPDATE|REPLACE|ALTER)\b/im;
  for (const name of sqlFiles) {
    const source = fs.readFileSync(path.join(directory, name), "utf8");
    assert.doesNotMatch(source, forbidden, `${name} must remain a read-only analysis`);
  }
});

test("supplemental examples are explicitly named so they do not collide with numbered reports", () => {
  const supplemental = sqlFiles.filter((name) => name.startsWith("supplemental_"));
  assert.ok(supplemental.length >= 1, "expected supplemental reports to remain available");
  assert.equal(numberedFiles.length + supplemental.length, sqlFiles.length,
    "every SQL file must be either numbered or explicitly supplemental");
});
