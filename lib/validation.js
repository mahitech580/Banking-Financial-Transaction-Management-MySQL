"use strict";

const ALLOWED_TRANSACTION_STATUSES = new Set(["PENDING", "SUCCESS", "FAILED", "REVERSED"]);
const MAX_TRANSFER_AMOUNT = 1_000_000_000_000;
const MAX_PAGE_SIZE = 300;
const MAX_PAGE_OFFSET = 100_000;

function normalizeSearchTerm(value, maximumLength = 100) {
  if (!Number.isSafeInteger(maximumLength) || maximumLength < 1) {
    throw new RangeError("maximumLength must be a positive safe integer");
  }
  return String(value ?? "").trim().slice(0, maximumLength);
}

function parseTransactionStatus(value) {
  const status = normalizeSearchTerm(value, 20).toUpperCase();
  if (!status) return { ok: true, value: "" };
  if (!ALLOWED_TRANSACTION_STATUSES.has(status)) {
    return {
      ok: false,
      error: "Invalid status filter. Use PENDING, SUCCESS, FAILED, or REVERSED."
    };
  }
  return { ok: true, value: status };
}

function parsePagination(query = {}, options = {}) {
  const defaultLimit = options.defaultLimit ?? 100;
  const maxLimit = options.maxLimit ?? MAX_PAGE_SIZE;
  const maxOffset = options.maxOffset ?? MAX_PAGE_OFFSET;

  if (!Number.isSafeInteger(defaultLimit) || defaultLimit < 1 ||
      !Number.isSafeInteger(maxLimit) || maxLimit < 1 || defaultLimit > maxLimit ||
      !Number.isSafeInteger(maxOffset) || maxOffset < 0) {
    throw new RangeError("Invalid pagination configuration");
  }

  const rawLimit = query.limit;
  const rawOffset = query.offset;
  const limit = rawLimit === undefined || rawLimit === "" ? defaultLimit : Number(rawLimit);
  const offset = rawOffset === undefined || rawOffset === "" ? 0 : Number(rawOffset);

  if (!Number.isSafeInteger(limit) || limit < 1) {
    return { ok: false, error: "limit must be a positive integer." };
  }
  if (!Number.isSafeInteger(offset) || offset < 0 || offset > maxOffset) {
    return { ok: false, error: `offset must be an integer between 0 and ${maxOffset}.` };
  }

  return { ok: true, limit: Math.min(limit, maxLimit), offset };
}

function validateTransferPayload(body) {
  const fromAccountId = Number(body?.fromAccountId);
  const toAccountId = Number(body?.toAccountId);
  const amount = Number(body?.amount);

  if (!Number.isSafeInteger(fromAccountId) || fromAccountId < 1 ||
      !Number.isSafeInteger(toAccountId) || toAccountId < 1) {
    return { ok: false, error: "Choose valid source and destination accounts." };
  }
  if (fromAccountId === toAccountId) {
    return { ok: false, error: "Source and destination accounts must be different." };
  }
  const roundedAmount = Math.round(amount * 100) / 100;
  if (!Number.isFinite(amount) || amount <= 0 ||
      Math.abs(amount - roundedAmount) > 1e-9 ||
      amount > MAX_TRANSFER_AMOUNT) {
    return { ok: false, error: "Enter an amount greater than zero with at most two decimal places." };
  }

  return {
    ok: true,
    value: { fromAccountId, toAccountId, amount, amountSql: roundedAmount.toFixed(2) }
  };
}

module.exports = {
  ALLOWED_TRANSACTION_STATUSES,
  MAX_PAGE_OFFSET,
  MAX_PAGE_SIZE,
  MAX_TRANSFER_AMOUNT,
  normalizeSearchTerm,
  parsePagination,
  parseTransactionStatus,
  validateTransferPayload
};
