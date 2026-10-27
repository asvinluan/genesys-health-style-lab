'use strict';

// Genesys Cloud Function Data Action: turn a spoken or typed reference number into the standard form.
// AWS equivalent: a small Python Lambda behind an Amazon Connect contact flow.
//
// Standard form: DH-YYYY-NNNNNN, for example DH-2026-000123.
// The caller may say "D H two zero two six zero zero zero one two three" or type DH2026000123.
// The function never calls anything outside itself and never logs the input.
// It handles a reference number only. It never receives a name, a date of birth or a document number.

const PREFIX = 'DH';

const WORDS = {
  zero: '0', oh: '0', o: '0',
  one: '1', two: '2', three: '3', four: '4', five: '5',
  six: '6', seven: '7', eight: '8', nine: '9',
};

function toCompact(raw) {
  const tokens = String(raw || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, ' ')
    .split(/[\s-]+/)
    .filter(Boolean);

  // Spoken digits become numbers. Letters are kept as they are.
  return tokens
    .map((t) => (Object.prototype.hasOwnProperty.call(WORDS, t) ? WORDS[t] : t))
    .join('')
    .toUpperCase();
}

function normaliseReference(raw) {
  const compact = toCompact(raw);
  const match = new RegExp(`^${PREFIX}(20\\d{2})(\\d{6})$`).exec(compact);

  if (!match) {
    return { valid: false, reference: '', reason: 'format' };
  }
  return { valid: true, reference: `${PREFIX}-${match[1]}-${match[2]}`, reason: 'ok' };
}

// Genesys calls handler(event). The event is the action's input contract. The return value is the output contract.
exports.handler = async (event) => normaliseReference(event && event.spoken);
exports.normaliseReference = normaliseReference;
