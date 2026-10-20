"use strict";

function maskCardNumber(value) {
  const raw = String(value ?? "").trim();
  if (!raw) return "";
  const digits = raw.replace(/\\D/g, "");
  if (!digits) return "••••";
  return "•••• " + digits.slice(-4);
}

module.exports = { maskCardNumber };
