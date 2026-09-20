import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixrwanda/core/exceptions.dart';
import 'package:fixrwanda/data/local_marketplace_store.dart';
import 'package:fixrwanda/models/booking.dart';
import 'package:fixrwanda/models/payment.dart';
import 'package:fixrwanda/models/review.dart';
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

  test('failed payment leaves the booking pending', () async {
    final store = await signedInStore();
    final booking = await store.createBooking(
      CreateBookingInput(
        professionalId: 'pro-0',
        serviceId: 'pro-0-s0',
        serviceName: 'Wiring inspection',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledTime: '09:00',
        customerAddress: 'KN 5 Ave, Kacyiru',
        servicePrice: 25000,
      ),
    );
    final payment = await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788000000',
    );
    expect(payment.status, PaymentStatus.failed);
    final pending = await store.getBookingById(booking.id);
    expect(pending?.status, BookingStatus.pending);
  });

  test('successful payment confirms the booking', () async {
    final store = await signedInStore();
    final booking = await store.createBooking(
      CreateBookingInput(
        professionalId: 'pro-0',
        serviceId: 'pro-0-s0',
        serviceName: 'Wiring inspection',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledTime: '09:00',
        customerAddress: 'KN 5 Ave, Kacyiru',
        servicePrice: 25000,
      ),
    );
    final payment = await store.payBooking(
      bookingId: booking.id,
      method: PaymentMethod.mtnMomo,
      phoneNumber: '+250788123456',
    );
    expect(payment.status, PaymentStatus.success);
    final confirmed = await store.getBookingById(booking.id);
    expect(confirmed?.status, BookingStatus.confirmed);
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

  test('unverified professionals cannot be booked', () async {
    final store = await signedInStore();
    expect(
      () => store.createBooking(
        CreateBookingInput(
          professionalId: 'pro-5',
          serviceId: 'pro-5-s0',
          serviceName: 'Engine diagnostics',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          scheduledTime: '09:00',
          customerAddress: 'Gikondo',
          servicePrice: 30000,
        ),
      ),
      throwsA(isA<MarketplaceException>()),
    );
  });
}
