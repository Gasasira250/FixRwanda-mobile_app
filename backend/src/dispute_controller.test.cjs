const test = require('node:test');
const assert = require('node:assert/strict');
const { openDispute, adminRefund, adminPayout } = require('./dispute_controller.cjs');

const disputedJob = () => ({
  id: 'job-9',
  status: 'inProgress',
  amount_rwf: 20000,
  payment_state: 'HELD_IN_ESCROW',
  before_photo_url: 'https://s3.amazonaws.com/jobs/before.jpg',
  after_photo_url: 'https://s3.amazonaws.com/jobs/after.jpg',
});

test('client can open a dispute while escrow is held', () => {
  const next = openDispute(disputedJob(), {
    reason: 'The outlet is still dead after the visit.',
  });
  assert.equal(next.status, 'DISPUTED');
});

test('admin can refund or override payout on a disputed job', () => {
  const disputed = openDispute(disputedJob(), {
    reason: 'Water leak returned after one hour.',
  });
  const refunded = adminRefund(disputed);
  assert.equal(refunded.booking.payment_state, 'REFUNDED');
  const paid = adminPayout(disputed);
  assert.equal(paid.booking.payment_state, 'DISBURSED_TO_PROVIDER');
  assert.equal(paid.payout.providerPayoutRwf, 17000);
});
