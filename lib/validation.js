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

  const limit = query.limit === undefined || query.limit === "" ? defaultLimit : Number(query.limit);
  const offset = query.offset === undefined || query.offset === "" ? 0 : Number(query.offset);
  if (!Number.isSafeInteger(limit) || limit < 1) return { ok: false, error: "limit must be a positive integer." };
  if (!Number.isSafeInteger(offset) || offset < 0 || offset > maxOffset) {
    return { ok: false, error: `offset must be an integer between 0 and ${maxOffset}.` };
  }
  return { ok: true, limit: Math.min(limit, maxLimit), offset };
}

function isAsciiDigits(text) {
  if (!text) return false;
  for (const char of text) {
    if (char < "0" || char > "9") return false;
  }
  return true;
}

function parseAccountId(value) {
  if (typeof value === "number") return value;
  if (typeof value !== "string") return NaN;
  const text = value.trim();
  if (!isAsciiDigits(text)) return NaN;
  return Number(text);
}

function parseAmount(value) {
  if (typeof value === "number") return value;
  if (typeof value !== "string") return NaN;
  const text = value.trim();
  const parts = text.split(".");
  if (parts.length > 2) return NaN;
  if (parts.length === 1 && !isAsciiDigits(parts[0])) return NaN;
  if (parts.length === 2) {
    const whole = parts[0];
    const fraction = parts[1];
    if ((whole && !isAsciiDigits(whole)) ||
        !isAsciiDigits(fraction) || fraction.length > 2) return NaN;
    if (!whole && !fraction) return NaN;
  }
  return Number(text);
}

function validateTransferPayload(body) {
  const fromAccountId = parseAccountId(body?.fromAccountId);
  const toAccountId = parseAccountId(body?.toAccountId);
  const amount = parseAmount(body?.amount);

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
  return { ok: true, value: { fromAccountId, toAccountId, amount, amountSql: roundedAmount.toFixed(2) } };
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
