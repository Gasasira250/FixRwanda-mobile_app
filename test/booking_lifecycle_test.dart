import 'package:flutter_test/flutter_test.dart';
import 'package:fixrwanda/domain/booking_lifecycle.dart';
import 'package:fixrwanda/models/booking.dart';

void main() {
  test('allows pending to confirmed and confirmed to enRoute', () {
    expect(
      BookingLifecycle.canTransition(
        BookingStatus.pending,
        BookingStatus.confirmed,
      ),
      isTrue,
    );
    expect(
      BookingLifecycle.transition(
        BookingStatus.confirmed,
        BookingStatus.enRoute,
      ),
      BookingStatus.enRoute,
    );
  });

  test('rejects completed to cancelled', () {
    expect(
      () => BookingLifecycle.transition(
        BookingStatus.completed,
        BookingStatus.cancelled,
      ),
      throwsA(isA<InvalidBookingTransition>()),
    );
  });

  test('rejects inProgress to cancelled', () {
    expect(
      BookingLifecycle.canTransition(
        BookingStatus.inProgress,
        BookingStatus.cancelled,
      ),
      isFalse,
    );
  });
}
