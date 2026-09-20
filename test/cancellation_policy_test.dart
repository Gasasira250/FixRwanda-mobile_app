import 'package:flutter_test/flutter_test.dart';
import 'package:fixrwanda/domain/cancellation_policy.dart';
import 'package:fixrwanda/models/booking.dart';

Booking booking(BookingStatus status, {int price = 20000}) {
  return Booking(
    id: 'b1',
    customerId: 'c1',
    professionalId: 'p1',
    serviceId: 's1',
    serviceName: 'Leak repair',
    professionalName: 'Aline Uwase',
    scheduledDate: DateTime(2026, 9, 21),
    scheduledTime: '10:00',
    customerAddress: 'Kacyiru',
    servicePrice: price,
    status: status,
    createdAt: DateTime(2026, 9, 20),
  );
}

void main() {
  test('accepted bookings refund in full before travel', () {
    final item = booking(BookingStatus.accepted);
    expect(CancellationPolicy.canCancelBooking(item), isTrue);
    expect(CancellationPolicy.calculateCancellationFee(item), 0);
    expect(CancellationPolicy.calculateRefundAmount(item), 20000);
  });

  test('enRoute bookings withhold 2000 RWF transport', () {
    final item = booking(BookingStatus.enRoute);
    expect(CancellationPolicy.calculateCancellationFee(item), 2000);
    expect(CancellationPolicy.calculateRefundAmount(item), 18000);
  });

  test('awaiting OTP cannot be cancelled', () {
    final item = booking(BookingStatus.awaitingOtp);
    expect(CancellationPolicy.canCancelBooking(item), isFalse);
  });
}
