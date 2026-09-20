import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../data/local_marketplace_store.dart';
import '../models/booking.dart';
import '../models/escrow.dart';
import '../models/job_message.dart';
import '../models/payment.dart';
import '../models/professional.dart';
import '../models/provider_verification.dart';
import '../models/review.dart';
import '../models/service.dart';
import '../models/user.dart';
import '../repositories/booking_repository.dart';
import '../repositories/professional_repository.dart';
import '../tracking/device_location_source.dart';
import '../tracking/location_source.dart';

class MarketplaceController extends ChangeNotifier {
  MarketplaceController(this.store, {LocationSource? locationSource})
      : locationSource = locationSource ?? const DeviceLocationSource();

  final LocalMarketplaceStore store;
  final LocationSource locationSource;

  User? user;
  Professional? myProfessional;
  bool booting = true;
  bool busy = false;
  String? errorMessage;
  List<Professional> professionals = const [];
  List<Booking> bookings = const [];
  List<Booking> openJobs = const [];
  List<Booking> assignedJobs = const [];
  List<Booking> disputedJobs = const [];
  ProfessionalFilter filter = const ProfessionalFilter();
  Timer? _ticker;

  bool get isSignedIn => user != null;
  bool get isAdmin => user?.role == UserRole.admin;
  bool get isProfessional => user?.role == UserRole.professional;

  Future<void> boot() async {
    booting = true;
    notifyListeners();
    try {
      await store.initialize();
      user = await store.restoreSession();
      await refresh();
      if (isSignedIn) _startTicker();
    } finally {
      booting = false;
      notifyListeners();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) async {
      await store.expireStaleBroadcasts();
      if (isProfessional && myProfessional != null) {
        for (final job in assignedJobs.where(
          (item) => item.status == BookingStatus.enRoute,
        )) {
          final point = await locationSource.read(
            fallbackLatitude: job.providerLatitude ?? -1.9441,
            fallbackLongitude: job.providerLongitude ?? 30.0619,
          );
          await store.pushLocation(
            bookingId: job.id,
            latitude: point.latitude,
            longitude: point.longitude,
          );
        }
      }
      await refresh();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    await store.expireStaleBroadcasts();
    professionals = await store.filterProfessionals(filter);
    if (user != null) {
      myProfessional = store.professionalForUser(user!.id);
      if (isProfessional && myProfessional != null) {
        openJobs = await store.openBroadcastsForProfessional(myProfessional!.id);
        assignedJobs =
            await store.assignedJobsForProfessional(myProfessional!.id);
        bookings = assignedJobs;
      } else {
        bookings = await store.getBookingsForCustomer(user!.id);
        openJobs = const [];
        assignedJobs = const [];
      }
      if (isAdmin) {
        disputedJobs = await store.disputedBookings();
      }
    } else {
      bookings = const [];
      openJobs = const [];
      assignedJobs = const [];
      disputedJobs = const [];
      myProfessional = null;
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
      _startTicker();
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
      _startTicker();
    });
  }

  Future<void> logout() async {
    _ticker?.cancel();
    await store.logout();
    user = null;
    myProfessional = null;
    bookings = const [];
    openJobs = const [];
    assignedJobs = const [];
    disputedJobs = const [];
    notifyListeners();
  }

  Future<Professional?> professionalById(String id) {
    return store.getProfessionalById(id);
  }

  List<Service> servicesFor(String professionalId) {
    return store.servicesForProfessional(professionalId);
  }

  List<Service> servicesForCategory(String category) {
    return store.servicesForCategory(category);
  }

  Future<List<Review>> reviewsFor(String professionalId) {
    return store.getReviewsForProfessional(professionalId);
  }

  Future<Review?> reviewForBooking(String bookingId) {
    return store.getReviewForBooking(bookingId);
  }

  Payment? paymentFor(String bookingId) => store.paymentFor(bookingId);
  EscrowHold? escrowFor(String bookingId) => store.escrowFor(bookingId);

  Future<Booking?> createBooking(CreateBookingInput input) {
    return _job(() => store.createBooking(input));
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

  Future<Booking?> cancelBooking(String bookingId) {
    return _job(() => store.cancelBooking(bookingId));
  }

  Future<Booking?> acceptJob(String bookingId) {
    return _job(() => store.acceptJob(bookingId));
  }

  Future<Booking?> startTravel(String bookingId) {
    return _job(() => store.startTravel(bookingId));
  }

  Future<Booking?> markArrived(String bookingId) {
    return _job(() => store.markArrived(bookingId));
  }

  Future<Booking?> startJob(String bookingId, {required String photoRef}) {
    return _job(() => store.startJob(bookingId, photoRef: photoRef));
  }

  Future<Booking?> markWorkFinished(String bookingId, {required String otp}) {
    return _job(() => store.markWorkFinished(bookingId, otp: otp));
  }

  Future<Booking?> uploadAfterPhoto(String bookingId, {required String photoRef}) {
    return _job(() => store.uploadAfterPhoto(bookingId, photoRef: photoRef));
  }

  Future<Booking?> openDispute(String bookingId, {required String reason}) {
    return _job(() => store.openDispute(bookingId, reason: reason));
  }

  Future<Booking?> adminRefund(String bookingId) {
    return _job(() => store.adminRefund(bookingId));
  }

  Future<Booking?> adminPayout(String bookingId) {
    return _job(() => store.adminPayout(bookingId));
  }

  Future<JobMessage?> sendJobMessage({
    required String bookingId,
    required String body,
  }) async {
    try {
      errorMessage = null;
      final message = await store.sendJobMessage(bookingId: bookingId, body: body);
      await refresh();
      return message;
    } on MarketplaceException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return null;
    }
  }

  List<JobMessage> messagesFor(String bookingId) => store.messagesFor(bookingId);

  Future<Booking?> confirmCompletionWithOtp(String bookingId, String otp) {
    return _job(() => store.confirmCompletionWithOtp(bookingId, otp));
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
    try {
      errorMessage = null;
      await store.setOverallVerification(professionalId, status);
      await refresh();
    } on MarketplaceException catch (error) {
      errorMessage = error.message;
      notifyListeners();
    }
  }

  Future<Professional?> submitNidaKyc({
    required String nidaNumber,
    required String selfieRef,
  }) {
    return _profile(
      () => store.submitNidaKyc(nidaNumber: nidaNumber, selfieRef: selfieRef),
    );
  }

  Future<Professional?> submitIremboCertificate({required String documentRef}) {
    return _profile(() => store.submitIremboCertificate(documentRef: documentRef));
  }

  Future<Professional?> submitTradeCertificate({
    required TradeCertificateKind kind,
    required String documentRef,
  }) {
    return _profile(
      () => store.submitTradeCertificate(kind: kind, documentRef: documentRef),
    );
  }

  Map<String, dynamic>? verificationFlag(String professionalId) {
    try {
      return store.verificationFlag(professionalId);
    } on MarketplaceException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return null;
    }
  }

  Future<Professional?> _profile(Future<Professional> Function() action) async {
    try {
      errorMessage = null;
      busy = true;
      notifyListeners();
      final professional = await action();
      await refresh();
      return professional;
    } on MarketplaceException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Booking?> _job(Future<Booking> Function() action) async {
    try {
      errorMessage = null;
      busy = true;
      notifyListeners();
      final booking = await action();
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
