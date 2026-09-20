const { refundToClient } = require('./payment_service.cjs');

const DISPUTABLE = new Set([
  'arrived',
  'inProgress',
  'awaitingOtp',
  'IN_PROGRESS',
  'EN_ROUTE',
  'completed',
  'COMPLETED',
]);

function openDispute(booking, { reason, photoUrl }) {
  if (!DISPUTABLE.has(booking.status)) {
    throw new Error('This job cannot be disputed.');
  }
  if (booking.payment_state === 'DISBURSED_TO_PROVIDER') {
    throw new Error('Payout already left escrow. Contact FixRwanda admin.');
  }
  if (!reason || String(reason).trim().length < 8) {
    throw new Error('Explain the dispute in at least 8 characters.');
  }
  return {
    ...booking,
    status: 'DISPUTED',
    disputeReason: String(reason).trim(),
    after_photo_url: photoUrl || booking.after_photo_url,
  };
}

function adminRefund(booking) {
  if (booking.status !== 'DISPUTED' && booking.status !== 'disputed') {
    throw new Error('Admin refund is only available on disputed jobs.');
  }
  return refundToClient(booking);
}

function adminPayout(booking) {
  if (booking.status !== 'DISPUTED' && booking.status !== 'disputed') {
    throw new Error('Admin payout override is only available on disputed jobs.');
  }
  const amount = Number(booking.amount_rwf ?? booking.servicePrice ?? 0);
  const fee = Math.round(amount * 0.15);
  return {
    booking: {
      ...booking,
      status: 'COMPLETED',
      payment_state: 'DISBURSED_TO_PROVIDER',
    },
    payout: {
      providerPayoutRwf: amount - fee,
      marketplaceFeeRwf: fee,
    },
  };
}

module.exports = {
  openDispute,
  adminRefund,
  adminPayout,
};
