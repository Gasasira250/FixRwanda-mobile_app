import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../data/local_marketplace_store.dart';
import '../domain/booking_lifecycle.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/professional.dart';
import '../models/review.dart';
import '../models/service.dart';
import '../models/user.dart';
import '../repositories/booking_repository.dart';
import '../repositories/professional_repository.dart';

class MarketplaceController extends ChangeNotifier {
  MarketplaceController(this.store);

  final LocalMarketplaceStore store;

  User? user;
  bool booting = true;
  bool busy = false;
  String? errorMessage;
  List<Professional> professionals = const [];
  List<Booking> bookings = const [];
  ProfessionalFilter filter = const ProfessionalFilter();

  bool get isSignedIn => user != null;
  bool get isAdmin => user?.role == UserRole.admin;

  Future<void> boot() async {
    booting = true;
    notifyListeners();
    try {
      await store.initialize();
      user = await store.restoreSession();
      await refresh();
    } finally {
      booting = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    professionals = await store.filterProfessionals(filter);
    if (user != null) {
      bookings = await store.getBookingsForCustomer(user!.id);
    } else {
      bookings = const [];
    }
    notifyListeners();
  }

  Future<void> applyFilter(ProfessionalFilter next) async {
    filter = next;
    await refresh();
  }

  Future<bool> login(String identifier, String password) async {
    return _run(() async {
      user = await store.login(identifier: identifier, password: password);
      await refresh();
    });
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    UserRole role = UserRole.customer,
  }) async {
    return _run(() async {
      user = await store.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );
      await refresh();
    });
  }

  Future<void> logout() async {
    await store.logout();
    user = null;
    bookings = const [];
    notifyListeners();
  }

  Future<Professional?> professionalById(String id) {
    return store.getProfessionalById(id);
  }

  List<Service> servicesFor(String professionalId) {
    return store.servicesForProfessional(professionalId);
  }

  Future<List<Review>> reviewsFor(String professionalId) {
    return store.getReviewsForProfessional(professionalId);
  }

  Future<Review?> reviewForBooking(String bookingId) {
    return store.getReviewForBooking(bookingId);
  }

  Payment? paymentFor(String bookingId) => store.paymentFor(bookingId);

  Future<Booking?> createBooking(CreateBookingInput input) async {
    try {
      errorMessage = null;
      busy = true;
      notifyListeners();
      final booking = await store.createBooking(input);
      await refresh();
      return booking;
    } on MarketplaceException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Payment?> payBooking({
    required String bookingId,
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    try {
      errorMessage = null;
      busy = true;
      notifyListeners();
      final payment = await store.payBooking(
        bookingId: bookingId,
        method: method,
        phoneNumber: phoneNumber,
      );
      await refresh();
      return payment;
    } on MarketplaceException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Booking?> cancelBooking(String bookingId) async {
    try {
      errorMessage = null;
      busy = true;
      notifyListeners();
      final booking = await store.cancelBooking(bookingId);
      await refresh();
      return booking;
    } on MarketplaceException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Booking?> advanceBooking(String bookingId) async {
    final booking = await store.getBookingById(bookingId);
    if (booking == null) return null;
    final next = BookingLifecycle.nextProfessionalStatus(booking.status);
    if (next == null) return booking;
    final updated = await store.updateStatus(bookingId, next);
    await refresh();
    return updated;
  }

  Future<Review?> addReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      errorMessage = null;
      final review = await store.addReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      await refresh();
      return review;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Professional>> pendingVerifications() {
    return store.pendingVerifications();
  }

  Future<void> setVerification(
    String professionalId,
    VerificationStatus status,
  ) async {
    await store.setOverallVerification(professionalId, status);
    await refresh();
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
