'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { handler, normaliseReference } = require('./index.js');

const P = 'DH';

test('typed form', () => {
  assert.deepEqual(normaliseReference(`${P}2026000123`), { valid: true, reference: `${P}-2026-000123`, reason: 'ok' });
});

test('already standard', () => {
  assert.equal(normaliseReference(`${P.toLowerCase()}-2026-000123`).reference, `${P}-2026-000123`);
});

test('spoken digits', () => {
  const r = normaliseReference(`${P.split('').join(' ')} two zero two six zero zero zero one two three`);
  assert.equal(r.valid, true);
  assert.equal(r.reference, `${P}-2026-000123`);
});

test('oh for zero', () => {
  assert.equal(normaliseReference(`${P} 2026 oh oh oh four five six`).reference, `${P}-2026-000456`);
});

test('too short is invalid', () => {
  assert.deepEqual(normaliseReference(`${P}-2026-123`), { valid: false, reference: '', reason: 'format' });
});

test('wrong prefix is invalid', () => {
  assert.equal(normaliseReference('ZZ-2026-000123').valid, false);
});

test('a name or other text is never accepted or echoed', () => {
  const r = normaliseReference('John Citizen born 1 January 1980');
  assert.deepEqual(r, { valid: false, reference: '', reason: 'format' });
});

test('empty and missing input never throw', async () => {
  assert.equal((await handler({})).valid, false);
  assert.equal((await handler(undefined)).valid, false);
  assert.equal((await handler({ spoken: null })).valid, false);
});
