import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixrwanda/data/local_marketplace_store.dart';
import 'package:fixrwanda/models/booking.dart';
import 'package:fixrwanda/models/escrow.dart';
import 'package:fixrwanda/models/payment.dart';
import 'package:fixrwanda/repositories/booking_repository.dart';
import 'package:fixrwanda/tracking/location_source.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('held escrow can be disputed then refunded by admin', () async {
    final store = LocalMarketplaceStore();
    await store.login(
      identifier: 'hannington@fixrwanda.rw',
      password: 'rwanda123',
    );
    final booking = await store.createBooking(
      CreateBookingInput(
        serviceId: 'broadcast-s0',
        serviceName: 'Wiring inspection',
        category: 'Electrical Installation',
        scheduledDate: DateTime.now(),
        scheduledTime: 'Now',
        customerAddress: 'KN 5 Ave, Kacyiru',
        servicePrice: 20000,
        district: 'Gasabo',
      ),
    );
    await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788123456',
    );
    await store.login(identifier: 'jean@fixrwanda.rw', password: 'rwanda123');
    await store.acceptJob(booking.id);
    await store.startTravel(booking.id);
    await store.markArrived(booking.id);
    await store.startJob(booking.id, photoRef: 'before');
    await store.uploadAfterPhoto(booking.id, photoRef: 'after');

    await store.login(
      identifier: 'hannington@fixrwanda.rw',
      password: 'rwanda123',
    );
    final disputed = await store.openDispute(
      booking.id,
      reason: 'The breaker still trips when the kettle is on.',
    );
    expect(disputed.status, BookingStatus.disputed);
    expect(disputed.paymentState, PaymentState.heldInEscrow);

    await store.login(identifier: 'admin@fixrwanda.rw', password: 'admin123');
    final refunded = await store.adminRefund(booking.id);
    expect(refunded.status, BookingStatus.cancelled);
    expect(refunded.paymentState, PaymentState.refunded);
    expect(store.escrowFor(booking.id)?.status, EscrowStatus.refunded);
  });

  test('simulated location source moves while EN_ROUTE', () async {
    final source = SimulatedLocationSource();
    final first = await source.read(
      fallbackLatitude: -1.9441,
      fallbackLongitude: 30.0619,
    );
    final second = await source.read(
      fallbackLatitude: -1.9441,
      fallbackLongitude: 30.0619,
    );
    expect(second.latitude, greaterThan(first.latitude));
  });
}
