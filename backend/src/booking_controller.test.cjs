const test = require('node:test');
const assert = require('node:assert/strict');
const {
  startBroadcast,
  onBroadcastTimeout,
  generateCompletionOtp,
  providerCompleteWithOtp,
  canProviderSeeBroadcast,
} = require('./booking_controller.cjs');

function providers() {
  return [
    {
      id: 'a',
      verificationStatus: 'verified',
      kigaliGreenBadge: true,
      category: 'Electrical Installation',
      district: 'Gasabo',
      lat: -1.932,
      lng: 30.099,
    },
    {
      id: 'b',
      verificationStatus: 'verified',
      kigaliGreenBadge: true,
      category: 'Electrical Installation',
      district: 'Gasabo',
      lat: -1.94,
      lng: 30.11,
    },
    {
      id: 'c',
      verificationStatus: 'verified',
      kigaliGreenBadge: true,
      category: 'Electrical Installation',
      district: 'Gasabo',
      lat: -1.95,
      lng: 30.12,
    },
    {
      id: 'd',
      verificationStatus: 'verified',
      kigaliGreenBadge: true,
      category: 'Electrical Installation',
      district: 'Gasabo',
      lat: -1.96,
      lng: 30.13,
    },
    {
      id: 'kicukiro',
      verificationStatus: 'verified',
      kigaliGreenBadge: true,
      category: 'Electrical Installation',
      district: 'Kicukiro',
      lat: -1.978,
      lng: 30.104,
    },
    {
      id: 'unverified',
      verificationStatus: 'pending',
      category: 'Electrical Installation',
      district: 'Gasabo',
      lat: -1.933,
      lng: 30.1,
    },
  ];
}

const job = {
  id: 'job-1',
  category: 'Electrical Installation',
  district: 'Gasabo',
  servicePrice: 20000,
  status: 'pending',
};

test('startBroadcast offers only the closest verified provider in the district', () => {
  const live = startBroadcast(job, providers(), new Date('2026-09-20T10:00:00Z'));
  assert.equal(live.status, 'broadcasting');
  assert.deepEqual(live.currentOfferIds, ['a']);
  assert.equal(live.broadcastRound, 1);
  assert.equal(canProviderSeeBroadcast(live, 'a'), true);
  assert.equal(canProviderSeeBroadcast(live, 'b'), false);
  assert.equal(canProviderSeeBroadcast(live, 'kicukiro'), false);
});

test('15-minute miss routes to the next 3 closest verified providers', () => {
  const started = startBroadcast(job, providers(), new Date('2026-09-20T10:00:00Z'));
  const { booking, rerouted, expired } = onBroadcastTimeout(
    started,
    providers(),
    new Date('2026-09-20T10:15:01Z'),
  );
  assert.equal(rerouted, true);
  assert.equal(expired, false);
  assert.equal(booking.broadcastRound, 2);
  assert.deepEqual(booking.currentOfferIds, ['b', 'c', 'd']);
  assert.equal(canProviderSeeBroadcast(booking, 'a'), false);
  assert.equal(canProviderSeeBroadcast(booking, 'b'), true);
});

test('second timeout expires when no verified providers remain', () => {
  const started = startBroadcast(job, providers(), new Date('2026-09-20T10:00:00Z'));
  const round2 = onBroadcastTimeout(
    started,
    providers(),
    new Date('2026-09-20T10:15:01Z'),
  ).booking;
  const { booking, expired } = onBroadcastTimeout(
    round2,
    providers(),
    new Date('2026-09-20T10:30:02Z'),
  );
  assert.equal(expired, true);
  assert.equal(booking.status, 'expired');
  assert.equal(booking.refundAmountRwf, 20000);
});

test('wrong completion OTP blocks payout', () => {
  const inProgress = {
    ...job,
    status: 'inProgress',
    completionOtp: '4821',
  };
  assert.throws(
    () => providerCompleteWithOtp(inProgress, '0000'),
    /incorrect/,
  );
});

test('correct 4-digit client OTP releases 85 percent to the provider', () => {
  const otp = generateCompletionOtp();
  assert.match(otp, /^\d{4}$/);
  const result = providerCompleteWithOtp(
    { ...job, status: 'inProgress', completionOtp: otp },
    otp,
  );
  assert.equal(result.booking.status, 'completed');
  assert.equal(result.payout.providerPayoutRwf, 17000);
  assert.equal(result.payout.marketplaceFeeRwf, 3000);
});
