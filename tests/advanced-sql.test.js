const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const directory = path.join(__dirname, "..", "advanced_sql");
const sqlFiles = fs.readdirSync(directory).filter((name) => /^\d{3}_.+\.sql$/.test(name)).sort();

test("advanced SQL library has unique, sequentially named case studies", () => {
  assert.ok(sqlFiles.length >= 296, "expected the documented 296-case advanced SQL library");
  assert.equal(new Set(sqlFiles).size, sqlFiles.length, "filenames must be unique");
  for (const [index, name] of sqlFiles.entries()) {
    assert.equal(Number(name.slice(0, 3)), index + 1, `unexpected sequence at ${name}`);
  }
});

test("advanced SQL case studies are distinct and read-only SELECT/CTE examples", () => {
  const sources = sqlFiles.map((name) => fs.readFileSync(path.join(directory, name), "utf8").trim());
  assert.equal(new Set(sources).size, sources.length, "case-study contents must not be duplicates");
  for (const [index, source] of sources.entries()) {
    const executable = source.replace(/^--.*$/gm, "").trimStart();
    assert.match(executable, /^(WITH\b|SELECT\b)/i, `${sqlFiles[index]} must start with a read-only SELECT or CTE`);
  }
});

test("every advanced SQL case study has a meaningful introductory comment", () => {
  for (const name of sqlFiles) {
    const source = fs.readFileSync(path.join(directory, name), "utf8");
    assert.match(source.trimStart(), /^--\s+\S/m, `${name} needs an introductory comment`);
    assert.ok(source.trim().length > 80, `${name} looks incomplete`);
  }
});

test("advanced SQL examples do not start with obvious data-changing statements", () => {
  const forbidden = /^\s*(DROP|TRUNCATE|DELETE|INSERT|UPDATE|REPLACE|ALTER)\b/im;
  for (const name of sqlFiles) {
    const source = fs.readFileSync(path.join(directory, name), "utf8");
    assert.doesNotMatch(source, forbidden, `${name} must remain read-only`);
  }
});
