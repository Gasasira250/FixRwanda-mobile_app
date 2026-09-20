import 'package:flutter_test/flutter_test.dart';
import 'package:fixrwanda/domain/booking_lifecycle.dart';
import 'package:fixrwanda/models/booking.dart';

void main() {
  test('pending escrow can broadcast, then a provider can accept', () {
    expect(
      BookingLifecycle.canTransition(
        BookingStatus.pending,
        BookingStatus.broadcasting,
      ),
      isTrue,
    );
    expect(
      BookingLifecycle.transition(
        BookingStatus.broadcasting,
        BookingStatus.accepted,
      ),
      BookingStatus.accepted,
    );
  });

  test('inProgress completes after the provider OTP gate', () {
    expect(
      BookingLifecycle.canTransition(
        BookingStatus.inProgress,
        BookingStatus.completed,
      ),
      isTrue,
    );
    expect(
      BookingLifecycle.canTransition(
        BookingStatus.awaitingOtp,
        BookingStatus.completed,
      ),
      isTrue,
    );
  });

  test('inProgress can be disputed for admin review', () {
    expect(
      BookingLifecycle.canTransition(
        BookingStatus.inProgress,
        BookingStatus.disputed,
      ),
      isTrue,
    );
    expect(
      BookingLifecycle.canTransition(
        BookingStatus.disputed,
        BookingStatus.cancelled,
      ),
      isTrue,
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
