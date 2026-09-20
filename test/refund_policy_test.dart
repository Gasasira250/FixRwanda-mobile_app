import 'package:fix_rwanda/models/booking.dart';
import 'package:fix_rwanda/services/refund_policy.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _booking(BookingStatus status, {int fee = 30000}) {
  return Booking(
    id: 'FR-000001',
    professionalId: 'pro-jean',
    professionalName: 'Jean Mugabo Electrical',
    trade: 'Electrician',
    service: 'House wiring',
    scheduledAt: DateTime(2026, 9, 25, 10),
    location: 'Kigali',
    description: 'Wiring',
    serviceFeeRwf: fee,
    status: status,
    paymentMethod: PaymentMethod.mtnMomo,
    paid: true,
    createdAt: DateTime(2026, 9, 19, 9),
  );
}

void main() {
  test('confirmed bookings refund in full', () {
    final quote = RefundPolicy.quote(_booking(BookingStatus.confirmed));
    expect(quote.canCancel, isTrue);
    expect(quote.cancellationFeeRwf, 0);
    expect(quote.refundAmountRwf, 30000);
  });

  test('en route bookings withhold a 2000 RWF transport fee', () {
    final quote = RefundPolicy.quote(_booking(BookingStatus.enRoute));
    expect(quote.canCancel, isTrue);
    expect(quote.cancellationFeeRwf, 2000);
    expect(quote.refundAmountRwf, 28000);
  });

  test('jobs in progress refund half the fee', () {
    final quote = RefundPolicy.quote(_booking(BookingStatus.inProgress));
    expect(quote.canCancel, isTrue);
    expect(quote.refundAmountRwf, 15000);
    expect(quote.cancellationFeeRwf, 15000);
  });

  test('completed bookings cannot be cancelled', () {
    final quote = RefundPolicy.quote(_booking(BookingStatus.completed));
    expect(quote.canCancel, isFalse);
    expect(quote.refundAmountRwf, 0);
  });
}
