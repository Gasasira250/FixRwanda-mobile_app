const test = require('node:test');
const assert = require('node:assert/strict');
const {
  requestToPay,
  applyCollectionWebhook,
  transferToProvider,
} = require('./payment_service.cjs');

test('Book Now calls RequestToPay and keeps funds initiated until the webhook', () => {
  const collection = requestToPay({
    bookingId: 'job-1',
    amountRwf: 20000,
    msisdn: '+250788123456',
  });
  assert.equal(collection.ok, true);
  assert.equal(collection.payment_state, 'INITIATED');
  assert.equal(collection.collection.path, '/collection/v1_0/requesttopay');
});

test('successful collection webhook moves money to HELD_IN_ESCROW', () => {
  const { booking, held } = applyCollectionWebhook(
    { id: 'job-1', amount_rwf: 20000, payment_state: 'INITIATED' },
    { status: 'SUCCESSFUL' },
  );
  assert.equal(held, true);
  assert.equal(booking.payment_state, 'HELD_IN_ESCROW');
  assert.equal(booking.platform_fee_rwf, 3000);
});

test('OTP verification transfers 85 percent through Disbursement Transfer', () => {
  const result = transferToProvider(
    {
      id: 'job-1',
      amount_rwf: 20000,
      servicePrice: 20000,
      status: 'inProgress',
      completionOtp: '4821',
      payment_state: 'HELD_IN_ESCROW',
    },
    { otp: '4821', providerMsisdn: '+250788555111' },
  );
  assert.equal(result.booking.payment_state, 'DISBURSED_TO_PROVIDER');
  assert.equal(result.booking.status, 'COMPLETED');
  assert.equal(result.payout.providerPayoutRwf, 17000);
  assert.equal(result.disbursement.path, '/disbursement/v1_0/transfer');
  assert.equal(result.disbursement.amount, '17000');
});
