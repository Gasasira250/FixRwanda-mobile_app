export const TRANSPORT_FEE_RWF = 2000;

export function quoteCancellation(booking) {
  const fee = booking.serviceFeeRwf ?? booking.service_fee_rwf;
  const status = booking.status;

  if (status === 'cancelled') {
    return {
      canCancel: false,
      cancellationFeeRwf: booking.cancellationFeeRwf ?? booking.cancellation_fee_rwf ?? 0,
      refundAmountRwf: booking.refundAmountRwf ?? booking.refund_amount_rwf ?? 0,
      title: 'Already cancelled',
      message: 'This booking is already cancelled.',
    };
  }

  if (status === 'completed') {
    return {
      canCancel: false,
      cancellationFeeRwf: 0,
      refundAmountRwf: 0,
      title: "Cancellation isn't available",
      message: 'Completed bookings cannot be cancelled.',
    };
  }

  if (status === 'confirmed') {
    return {
      canCancel: true,
      cancellationFeeRwf: 0,
      refundAmountRwf: fee,
      title: 'Cancel booking',
      message: `The professional has not started travelling. You will receive a full refund of ${fee} RWF.`,
    };
  }

  if (status === 'inProgress') {
    const refund = Math.floor(fee / 2);
    return {
      canCancel: true,
      cancellationFeeRwf: fee - refund,
      refundAmountRwf: refund,
      title: 'Job already in progress',
      message:
        'Work has started. Half of the service fee is refunded; the rest covers time already spent.',
    };
  }

  const refund = Math.max(0, fee - TRANSPORT_FEE_RWF);
  const onTheWay = status === 'enRoute';
  return {
    canCancel: true,
    cancellationFeeRwf: TRANSPORT_FEE_RWF,
    refundAmountRwf: refund,
    title: onTheWay
      ? 'Professional is already on the way'
      : 'Professional is already on site',
    message: `A ${TRANSPORT_FEE_RWF} RWF transport fee is withheld. Refund: ${refund} RWF.`,
  };
}

export function nextStatus(status) {
  return {
    confirmed: 'enRoute',
    enRoute: 'arrived',
    arrived: 'inProgress',
    inProgress: 'completed',
  }[status];
}

export function mockPayment(method) {
  const stamp = Date.now().toString().slice(-6);
  const prefix = {
    mtnMomo: 'MOM',
    airtelMoney: 'AIR',
    card: 'CARD',
  }[method] || 'PAY';
  return {
    status: 'success',
    providerReference: `${prefix}-${stamp}`,
    method,
  };
}

export function normalizeRwandaPhone(phone) {
  const digits = String(phone || '').replace(/\D/g, '');
  if (digits.startsWith('250') && digits.length === 12) {
    return `0${digits.slice(3)}`;
  }
  if (digits.startsWith('0') && digits.length === 10) return digits;
  return digits;
}

export function isValidMoMoPhone(phone, method) {
  const local = normalizeRwandaPhone(phone);
  if (!/^07\d{8}$/.test(local)) return false;
  if (method === 'airtelMoney') return /^07[23]/.test(local);
  if (method === 'mtnMomo') return /^07[89]/.test(local);
  return /^07[2-9]/.test(local);
}

export function mockMoMoPush({ phoneNumber, amount, method = 'mtnMomo' }) {
  const local = normalizeRwandaPhone(phoneNumber);
  const stamp = Date.now().toString().slice(-6);
  const prefix = method === 'airtelMoney' ? 'AIR' : 'MOM';
  const ussdCode = method === 'airtelMoney' ? '*182#' : '*182*1*1#';
  return {
    success: true,
    status: 'Pending Processing',
    message: `USSD prompt sent to ${local}. Enter your PIN on the phone to pay ${amount} RWF.`,
    ussdCode,
    providerReference: `${prefix}-${stamp}`,
    phoneNumber: local,
    amount: Number(amount),
    method,
  };
}
