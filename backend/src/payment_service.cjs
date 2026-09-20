const { providerCompleteWithOtp } = require('./booking_controller.cjs');

const COLLECTION_PATH = '/collection/v1_0/requesttopay';
const TRANSFER_PATH = '/disbursement/v1_0/transfer';
const FEE_RATE = 0.15;

function normalizeMsisdn(value) {
  return String(value || '').replace(/\D/g, '');
}

function amountOf(booking) {
  return Number(booking.amount_rwf ?? booking.servicePrice ?? 0);
}

function requestToPay({ bookingId, amountRwf, msisdn, currency = 'RWF' }) {
  const phone = normalizeMsisdn(msisdn);
  if (!phone) {
    throw new Error('A MoMo number is required for collection.');
  }
  if (phone.endsWith('0000')) {
    return {
      ok: false,
      payment_state: 'INITIATED',
      referenceId: `momo-fail-${bookingId}`,
      momoStatus: 'FAILED',
    };
  }
  return {
    ok: true,
    payment_state: 'INITIATED',
    referenceId: `momo-rtp-${bookingId}`,
    momoStatus: 'PENDING',
    collection: {
      path: COLLECTION_PATH,
      amount: String(amountRwf),
      currency,
      payer: { partyIdType: 'MSISDN', partyId: phone },
    },
  };
}

function applyCollectionWebhook(booking, event) {
  if (event.status !== 'SUCCESSFUL') {
    return {
      booking: { ...booking, payment_state: 'INITIATED' },
      held: false,
    };
  }
  const amount = amountOf(booking);
  return {
    booking: {
      ...booking,
      payment_state: 'HELD_IN_ESCROW',
      platform_fee_rwf: Math.round(amount * FEE_RATE),
    },
    held: true,
  };
}

function transferToProvider(booking, { otp, providerMsisdn, currency = 'RWF' }) {
  if (booking.payment_state && booking.payment_state !== 'HELD_IN_ESCROW') {
    throw new Error('Escrow is not holding client funds.');
  }
  const completed = providerCompleteWithOtp(
    {
      ...booking,
      servicePrice: amountOf(booking),
      status: booking.status === 'IN_PROGRESS' ? 'inProgress' : booking.status,
    },
    otp,
  );
  const phone = normalizeMsisdn(providerMsisdn);
  return {
    booking: {
      ...completed.booking,
      status: 'COMPLETED',
      payment_state: 'DISBURSED_TO_PROVIDER',
    },
    disbursement: {
      path: TRANSFER_PATH,
      amount: String(completed.payout.providerPayoutRwf),
      currency,
      payee: { partyIdType: 'MSISDN', partyId: phone },
    },
    payout: completed.payout,
  };
}

function refundToClient(booking) {
  if (booking.payment_state === 'DISBURSED_TO_PROVIDER') {
    throw new Error('Funds were already sent to the provider.');
  }
  return {
    booking: {
      ...booking,
      status: 'CANCELLED',
      payment_state: 'REFUNDED',
      refundAmountRwf: amountOf(booking),
    },
  };
}

module.exports = {
  COLLECTION_PATH,
  TRANSFER_PATH,
  requestToPay,
  applyCollectionWebhook,
  transferToProvider,
  refundToClient,
};
