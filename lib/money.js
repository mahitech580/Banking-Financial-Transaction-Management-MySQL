"use strict";

function decimalToMinorUnits(value) {
  if (typeof value !== "string" && typeof value !== "number") return null;
  if (typeof value === "number" && !Number.isFinite(value)) return null;
  const text = String(value).trim();
  const match = /^(-?)(\\d+)(?:\\.(\\d{1,2}))?$/.exec(text);
  if (!match) return null;

  const whole = BigInt(match[2]);
  const fraction = BigInt((match[3] || "").padEnd(2, "0"));
  const magnitude = whole * 100n + fraction;
  return match[1] === "-" ? -magnitude : magnitude;
}

function hasSufficientFunds(balance, amount) {
  const balanceCents = decimalToMinorUnits(balance);
  const amountCents = decimalToMinorUnits(amount);
  return balanceCents !== null && amountCents !== null && balanceCents >= amountCents;
}

module.exports = { decimalToMinorUnits, hasSufficientFunds };
