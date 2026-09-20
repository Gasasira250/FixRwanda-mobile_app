import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixrwanda/core/exceptions.dart';
import 'package:fixrwanda/data/local_marketplace_store.dart';
import 'package:fixrwanda/models/booking.dart';
import 'package:fixrwanda/models/escrow.dart';
import 'package:fixrwanda/models/payment.dart';
import 'package:fixrwanda/models/review.dart';
import 'package:fixrwanda/models/user.dart';
import 'package:fixrwanda/repositories/booking_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<LocalMarketplaceStore> signedInStore() async {
    final store = LocalMarketplaceStore();
    await store.login(
      identifier: 'hannington@fixrwanda.rw',
      password: 'rwanda123',
    );
    return store;
  }

  Future<Booking> requestedJob(LocalMarketplaceStore store) {
    return store.createBooking(
      CreateBookingInput(
        serviceId: 'broadcast-s0',
        serviceName: 'Wiring inspection',
        category: 'Electrical Installation',
        scheduledDate: DateTime.now(),
        scheduledTime: 'Now',
        customerAddress: 'KN 5 Ave, Kacyiru',
        servicePrice: 25000,
        district: 'Gasabo',
        sector: 'Kacyiru',
      ),
    );
  }

  test('failed escrow leaves the booking pending', () async {
    final store = await signedInStore();
    final booking = await requestedJob(store);
    final payment = await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788000000',
    );
    expect(payment.status, PaymentStatus.failed);
    final pending = await store.getBookingById(booking.id);
    expect(pending?.status, BookingStatus.pending);
  });

  test('successful escrow offers the closest verified provider for 15 minutes', () async {
    final store = await signedInStore();
    final booking = await requestedJob(store);
    final payment = await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788123456',
    );
    expect(payment.status, PaymentStatus.success);
    final live = await store.getBookingById(booking.id);
    expect(live?.status, BookingStatus.broadcasting);
    expect(live?.district, 'Gasabo');
    expect(live?.broadcastRound, 1);
    expect(live?.currentOfferIds, ['pro-0']);
    expect(store.escrowFor(booking.id)?.status, EscrowStatus.held);
    expect(store.commissions, isEmpty);
  });

  test('verified provider in the current offer can accept, then client OTP releases 85 percent', () async {
    final store = await signedInStore();
    final booking = await requestedJob(store);
    await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788123456',
    );

    await store.login(identifier: 'jean@fixrwanda.rw', password: 'rwanda123');
    final accepted = await store.acceptJob(booking.id);
    expect(accepted.status, BookingStatus.accepted);
    expect(accepted.professionalName, 'Jean Bosco');

    await store.startTravel(booking.id);
    await store.markArrived(booking.id);
    final started = await store.startJob(booking.id, photoRef: 'arrival-photo');
    expect(started.status, BookingStatus.inProgress);
    expect(started.completionOtp, hasLength(4));
    expect(started.paymentState, PaymentState.heldInEscrow);

    await expectLater(
      store.markWorkFinished(booking.id, otp: started.completionOtp!),
      throwsA(isA<MarketplaceException>()),
    );

    await store.uploadAfterPhoto(booking.id, photoRef: 'after-photo');
    await expectLater(
      store.markWorkFinished(booking.id, otp: '0000'),
      throwsA(isA<MarketplaceException>()),
    );
    expect(store.escrowFor(booking.id)?.status, EscrowStatus.held);

    final completed = await store.markWorkFinished(
      booking.id,
      otp: started.completionOtp!,
    );
    expect(completed.status, BookingStatus.completed);
    expect(completed.paymentState, PaymentState.disbursedToProvider);
    final escrow = store.escrowFor(booking.id);
    expect(escrow?.status, EscrowStatus.released);
    expect(escrow?.providerPayoutRwf, 21250);
    expect(escrow?.marketplaceFeeRwf, 3750);
  });

  test('15-minute miss reroutes to the next 3 closest verified providers', () async {
    final store = await signedInStore();
    final booking = await requestedJob(store);
    await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788123456',
    );
    final rerouted = await store.expireStaleBroadcasts(
      now: DateTime.now().add(const Duration(minutes: 16)),
    );
    expect(rerouted, 0);
    final live = await store.getBookingById(booking.id);
    expect(live?.status, BookingStatus.broadcasting);
    expect(live?.broadcastRound, 2);
    expect(live?.currentOfferIds, hasLength(3));
    expect(live?.currentOfferIds.contains('pro-0'), isFalse);
    expect(store.escrowFor(booking.id)?.status, EscrowStatus.held);
  });

  test('second timeout expires and refunds escrow when nobody is left', () async {
    final store = await signedInStore();
    final booking = await requestedJob(store);
    await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788123456',
    );
    await store.expireStaleBroadcasts(
      now: DateTime.now().add(const Duration(minutes: 16)),
    );
    final count = await store.expireStaleBroadcasts(
      now: DateTime.now().add(const Duration(minutes: 32)),
    );
    expect(count, 1);
    final expired = await store.getBookingById(booking.id);
    expect(expired?.status, BookingStatus.expired);
    expect(store.escrowFor(booking.id)?.status, EscrowStatus.refunded);
  });

  test('reviews are allowed once after completion only', () async {
    final store = await signedInStore();
    expect(
      () => store.addReview(
        bookingId: 'b-seed-1',
        rating: 5,
        comment: 'Not completed',
      ),
      throwsA(isA<ReviewNotAllowedException>()),
    );

    await store.addReview(
      bookingId: 'b-seed-2',
      rating: 5,
      comment: 'Excellent work',
    );
    expect(
      () => store.addReview(
        bookingId: 'b-seed-2',
        rating: 4,
        comment: 'Again',
      ),
      throwsA(isA<DuplicateReviewException>()),
    );
  });

  test('unverified professionals cannot accept jobs', () async {
    final store = await signedInStore();
    final booking = await requestedJob(store);
    await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788123456',
    );
    await store.register(
      fullName: 'New Electrician',
      email: 'newlec@fixrwanda.rw',
      phoneNumber: '+250788999888',
      password: 'rwanda123',
      role: UserRole.professional,
    );
    expect(
      () => store.acceptJob(booking.id),
      throwsA(isA<MarketplaceException>()),
    );
  });
}
