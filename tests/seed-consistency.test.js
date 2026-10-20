"use strict";

const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");

const root = path.join(__dirname, "..");
const accountsSql = fs.readFileSync(path.join(root, "06_account_data.sql"), "utf8");
const transactionsSql = fs.readFileSync(path.join(root, "07_transaction_data.sql"), "utf8");

function insertValues(source, tableName) {
  const pattern = new RegExp("INSERT INTO\\s+" + tableName + "\\b[\\s\\S]*?\\bVALUES([\\s\\S]*?);", "i");
  const match = source.match(pattern);
  assert.ok(match, "expected INSERT seed data for " + tableName);
  return match[1];
}

function cents(value) {
  const [whole, fraction = ""] = String(value).split(".");
  return BigInt(whole) * 100n + BigInt((fraction + "00").slice(0, 2));
}

const accountTuples = [...insertValues(accountsSql, "accounts").matchAll(
  /\('([^']+)',\s*(\d+),\s*(\d+),\s*'[^']+',\s*'[^']+',\s*'[^']+',\s*(\d+(?:\.\d{1,2})?)\)/g
)];
const accounts = accountTuples.map((match, index) => ({
  accountId: index + 1,
  accountNumber: match[1],
  balanceCents: cents(match[4])
}));

const transactionTuples = [...insertValues(transactionsSql, "transactions").matchAll(
  /\((\d+),\s*'(CREDIT|DEBIT)',\s*(\d+(?:\.\d{1,2})?),\s*'[^']*',\s*'([^']+)',\s*'[^']+',\s*(?:NULL|\d+),\s*'(SUCCESS|FAILED|PENDING|REVERSED)'\)/g
)];
const transactions = transactionTuples.map((match, index) => ({
  transactionId: index + 1,
  accountId: Number(match[1]),
  type: match[2],
  amountCents: cents(match[3]),
  referenceCode: match[4],
  status: match[5]
}));

test("synthetic account balances reconcile to successful seeded ledger activity", () => {
  assert.equal(accounts.length, 10, "expected the ten synthetic account seed rows");
  assert.equal(transactions.length, 26, "expected all initial ledger rows to be parsed");
  assert.equal(new Set(transactions.map((row) => row.referenceCode)).size, transactions.length,
    "seeded ledger reference codes must be unique");

  const netByAccount = new Map(accounts.map((account) => [account.accountId, 0n]));
  for (const transaction of transactions) {
    assert.ok(netByAccount.has(transaction.accountId),
      "transaction references unknown seeded account " + transaction.accountId);
    if (transaction.status !== "SUCCESS") continue;
    const signedAmount = transaction.type === "CREDIT" ? transaction.amountCents : -transaction.amountCents;
    netByAccount.set(transaction.accountId, netByAccount.get(transaction.accountId) + signedAmount);
  }

  for (const account of accounts) {
    assert.equal(netByAccount.get(account.accountId), account.balanceCents,
      account.accountNumber + " balance must equal successful ledger net in cents");
  }
});

test("the seeded demo transfer links a successful debit to a matching credit", () => {
  const transferMatch = transactionsSql.match(
    /INSERT INTO transfers[\s\S]*?\bVALUES\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+(?:\.\d{1,2})?)\s*,\s*'[^']*'\s*,\s*'([A-Z]+)'\s*\)/i
  );
  assert.ok(transferMatch, "expected a seeded transfer record");
  const [transactionId, fromAccountId, toAccountId, amount, status] = [
    Number(transferMatch[1]), Number(transferMatch[2]), Number(transferMatch[3]),
    transferMatch[4], transferMatch[5]
  ];
  assert.equal(status, "COMPLETED");

  const outgoing = transactions.find((row) => row.transactionId === transactionId);
  assert.ok(outgoing, "transfer must reference an existing outgoing transaction");
  assert.equal(outgoing.accountId, fromAccountId);
  assert.equal(outgoing.type, "DEBIT");
  assert.equal(outgoing.status, "SUCCESS");
  assert.equal(outgoing.amountCents, cents(amount));
  assert.match(outgoing.referenceCode, /^TRF-OUT-/);

  const incoming = transactions.find((row) =>
    row.accountId === toAccountId &&
    row.type === "CREDIT" &&
    row.status === "SUCCESS" &&
    row.amountCents === cents(amount) &&
    /^TRF-IN-/.test(row.referenceCode)
  );
  assert.ok(incoming, "transfer must have a matching successful credit for the destination account");
});
