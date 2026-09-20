import 'package:shared_preferences/shared_preferences.dart';

import '../core/exceptions.dart';
import '../domain/booking_lifecycle.dart';
import '../domain/cancellation_policy.dart';
import '../domain/commission_service.dart';
import '../models/booking.dart';
import '../models/commission.dart';
import '../models/payment.dart';
import '../models/professional.dart';
import '../models/review.dart';
import '../models/service.dart';
import '../models/user.dart';
import '../payments/mock_providers.dart';
import '../payments/payment_provider.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/professional_repository.dart';
import '../repositories/review_repository.dart';
import 'catalog_services.dart';

class StoredAccount {
  StoredAccount({required this.user, required this.password});
  final User user;
  final String password;
}

class LocalMarketplaceStore
    implements
        AuthRepository,
        ProfessionalRepository,
        BookingRepository,
        ReviewRepository,
        AdminRepository {
  LocalMarketplaceStore({
    PaymentGateway? gateway,
    CommissionService? commissionService,
    this._preferences,
  })  : _gateway = gateway ?? buildMockPaymentGateway(),
        _commissionService = commissionService ?? const CommissionService();

  final PaymentGateway _gateway;
  final CommissionService _commissionService;
  SharedPreferences? _preferences;

  final Map<String, StoredAccount> _accounts = {};
  final List<Professional> _professionals = [];
  final List<Service> _services = [];
  final List<Booking> _bookings = [];
  final List<Payment> _payments = [];
  final List<Review> _reviews = [];
  final List<CommissionBreakdown> _commissions = [];
  String? _sessionUserId;

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
    if (_professionals.isEmpty) {
      _seed();
    }
    _sessionUserId = _preferences!.getString('session_user_id');
  }

  List<Service> servicesForProfessional(String professionalId) {
    return _services
        .where((service) => service.professionalId == professionalId)
        .toList();
  }

  Service? serviceById(String id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  List<CommissionBreakdown> get commissions => List.unmodifiable(_commissions);

  @override
  Future<User?> restoreSession() async {
    await initialize();
    final id = _sessionUserId;
    if (id == null) return null;
    return _accounts[id]?.user;
  }

  @override
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    await initialize();
    final trimmed = identifier.trim().toLowerCase();
    StoredAccount? match;
    for (final account in _accounts.values) {
      final email = account.user.email.toLowerCase();
      final phone = account.user.phoneNumber.replaceAll(' ', '');
      if (email == trimmed || phone == trimmed.replaceAll(' ', '')) {
        match = account;
        break;
      }
    }
    if (match == null || match.password != password) {
      throw AuthException('Email or password is incorrect.');
    }
    _sessionUserId = match.user.id;
    await _preferences?.setString('session_user_id', match.user.id);
    return match.user;
  }

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    await initialize();
    if (fullName.trim().length < 3) {
      throw AuthException('Enter your full name.');
    }
    if (!email.contains('@')) {
      throw AuthException('Enter a valid email address.');
    }
    if (phoneNumber.trim().length < 10) {
      throw AuthException('Enter a valid Rwanda phone number.');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }
    for (final account in _accounts.values) {
      if (account.user.email.toLowerCase() == email.trim().toLowerCase()) {
        throw AuthException('An account with this email already exists.');
      }
    }
    final user = User(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
      role: role,
      createdAt: DateTime.now(),
    );
    _accounts[user.id] = StoredAccount(user: user, password: password);
    _sessionUserId = user.id;
    await _preferences?.setString('session_user_id', user.id);
    return user;
  }

  @override
  Future<void> logout() async {
    _sessionUserId = null;
    await _preferences?.remove('session_user_id');
  }

  User currentUserOrThrow() {
    final id = _sessionUserId;
    if (id == null || !_accounts.containsKey(id)) {
      throw AuthException('Sign in to continue.');
    }
    return _accounts[id]!.user;
  }

  @override
  Future<List<Professional>> getProfessionals() async {
    await initialize();
    return List.unmodifiable(_professionals);
  }

  @override
  Future<List<Professional>> searchProfessionals(String query) {
    return filterProfessionals(ProfessionalFilter(query: query));
  }

  @override
  Future<List<Professional>> filterProfessionals(ProfessionalFilter filter) async {
    await initialize();
    var results = _professionals.toList();
    final query = filter.query?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      results = results.where((professional) {
        return professional.name.toLowerCase().contains(query) ||
            professional.category.toLowerCase().contains(query) ||
            professional.location.toLowerCase().contains(query) ||
            professional.description.toLowerCase().contains(query);
      }).toList();
    }
    if (filter.category != null && filter.category!.isNotEmpty) {
      results = results
          .where((professional) => professional.category == filter.category)
          .toList();
    }
    if (filter.location != null && filter.location!.isNotEmpty) {
      final location = filter.location!.toLowerCase();
      results = results.where((professional) {
        return professional.location.toLowerCase().contains(location) ||
            (professional.sector ?? '').toLowerCase().contains(location);
      }).toList();
    }
    if (filter.minRating != null) {
      results = results
          .where((professional) => professional.rating >= filter.minRating!)
          .toList();
    }
    if (filter.maxPrice != null) {
      results = results
          .where((professional) => professional.startingPrice <= filter.maxPrice!)
          .toList();
    }
    if (filter.verifiedOnly) {
      results = results.where((professional) => professional.isBookable).toList();
    }
    results.sort((a, b) {
      switch (filter.sort) {
        case ProfessionalSort.priceLow:
          return a.startingPrice.compareTo(b.startingPrice);
        case ProfessionalSort.priceHigh:
          return b.startingPrice.compareTo(a.startingPrice);
        case ProfessionalSort.jobs:
          return b.completedJobs.compareTo(a.completedJobs);
        case ProfessionalSort.rating:
          return b.rating.compareTo(a.rating);
      }
    });
    return results;
  }

  @override
  Future<Professional?> getProfessionalById(String id) async {
    await initialize();
    for (final professional in _professionals) {
      if (professional.id == id) return professional;
    }
    return null;
  }

  @override
  Future<List<Booking>> getBookingsForCustomer(String customerId) async {
    await initialize();
    final bookings = _bookings
        .where((booking) => booking.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    await initialize();
    for (final booking in _bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  @override
  Future<Booking> createBooking(CreateBookingInput input) async {
    await initialize();
    final customer = currentUserOrThrow();
    final professional = await getProfessionalById(input.professionalId);
    if (professional == null) {
      throw MarketplaceException('Professional was not found.');
    }
    if (!professional.isBookable) {
      throw MarketplaceException(
        'This professional is still under verification and cannot be booked yet.',
      );
    }
    final booking = Booking(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customer.id,
      professionalId: professional.id,
      serviceId: input.serviceId,
      serviceName: input.serviceName,
      professionalName: professional.name,
      scheduledDate: input.scheduledDate,
      scheduledTime: input.scheduledTime,
      customerAddress: input.customerAddress,
      servicePrice: input.servicePrice,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      district: input.district ?? 'Kigali',
      sector: input.sector,
    );
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<Payment> payBooking({
    required String bookingId,
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    await initialize();
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw MarketplaceException('Booking was not found.');
    }
    if (booking.status != BookingStatus.pending) {
      throw MarketplaceException('This booking is no longer awaiting payment.');
    }

    final pendingPayment = Payment(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: booking.id,
      method: method,
      amount: booking.servicePrice,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
    );
    _payments.add(pendingPayment);

    final result = await _gateway.charge(
      PaymentRequest(
        amountRwf: booking.servicePrice,
        method: method,
        phoneNumber: phoneNumber,
        bookingId: booking.id,
      ),
    );

    final settled = pendingPayment.copyWith(
      status: result.status,
      transactionReference: result.reference,
    );
    _replacePayment(settled);

    if (!result.isSuccess) {
      return settled;
    }

    final confirmed = booking.copyWith(
      status: BookingLifecycle.transition(
        booking.status,
        BookingStatus.confirmed,
      ),
      paymentId: settled.id,
    );
    _replaceBooking(confirmed);
    _commissions.add(_commissionService.calculate(booking.servicePrice));
    return settled;
  }

  @override
  Payment? paymentFor(String bookingId) {
    Payment? latest;
    for (final payment in _payments) {
      if (payment.bookingId == bookingId) latest = payment;
    }
    return latest;
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    await initialize();
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw MarketplaceException('Booking was not found.');
    }
    final quote = CancellationPolicy.quote(booking);
    if (!quote.canCancel) {
      throw MarketplaceException(quote.message);
    }
    BookingLifecycle.transition(booking.status, BookingStatus.cancelled);
    final cancelled = booking.copyWith(
      status: BookingStatus.cancelled,
      cancellationFeeRwf: quote.cancellationFeeRwf,
      refundAmountRwf: quote.refundAmountRwf,
      cancelledAt: DateTime.now(),
    );
    _replaceBooking(cancelled);
    return cancelled;
  }

  @override
  Future<Booking> updateStatus(String bookingId, BookingStatus status) async {
    await initialize();
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw MarketplaceException('Booking was not found.');
    }
    final next = BookingLifecycle.transition(booking.status, status);
    var updated = booking.copyWith(status: next);
    if (next == BookingStatus.completed) {
      final professional = await getProfessionalById(booking.professionalId);
      if (professional != null) {
        _replaceProfessional(
          professional.copyWith(completedJobs: professional.completedJobs + 1),
        );
      }
    }
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<List<Review>> getReviewsForProfessional(String professionalId) async {
    await initialize();
    return _reviews
        .where((review) => review.professionalId == professionalId)
        .toList();
  }

  @override
  Future<Review?> getReviewForBooking(String bookingId) async {
    await initialize();
    for (final review in _reviews) {
      if (review.bookingId == bookingId) return review;
    }
    return null;
  }

  @override
  Future<Review> addReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    await initialize();
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw MarketplaceException('Booking was not found.');
    }
    if (booking.status != BookingStatus.completed) {
      throw ReviewNotAllowedException();
    }
    if (await getReviewForBooking(bookingId) != null) {
      throw DuplicateReviewException();
    }
    if (rating < 1 || rating > 5) {
      throw MarketplaceException('Choose a rating between 1 and 5.');
    }
    final review = Review(
      id: 'r-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: booking.id,
      customerId: booking.customerId,
      professionalId: booking.professionalId,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );
    _reviews.add(review);
    _recalculateRating(booking.professionalId);
    return review;
  }

  @override
  Future<List<Professional>> pendingVerifications() async {
    await initialize();
    return _professionals
        .where(
          (professional) =>
              professional.verificationStatus == VerificationStatus.pending,
        )
        .toList();
  }

  @override
  Future<Professional> setOverallVerification(
    String professionalId,
    VerificationStatus status,
  ) async {
    await initialize();
    final professional = await getProfessionalById(professionalId);
    if (professional == null) {
      throw MarketplaceException('Professional was not found.');
    }
    final updated = professional.copyWith(
      verificationStatus: status,
      phoneVerified: status == VerificationStatus.verified
          ? true
          : professional.phoneVerified,
      idVerified: status == VerificationStatus.verified
          ? true
          : professional.idVerified,
      certificateVerified: status == VerificationStatus.verified
          ? true
          : professional.certificateVerified,
    );
    _replaceProfessional(updated);
    return updated;
  }

  void _replaceBooking(Booking booking) {
    final index = _bookings.indexWhere((item) => item.id == booking.id);
    if (index >= 0) _bookings[index] = booking;
  }

  void _replacePayment(Payment payment) {
    final index = _payments.indexWhere((item) => item.id == payment.id);
    if (index >= 0) {
      _payments[index] = payment;
    } else {
      _payments.add(payment);
    }
  }

  void _replaceProfessional(Professional professional) {
    final index =
        _professionals.indexWhere((item) => item.id == professional.id);
    if (index >= 0) _professionals[index] = professional;
  }

  void _recalculateRating(String professionalId) {
    final reviews = _reviews
        .where((review) => review.professionalId == professionalId)
        .toList();
    if (reviews.isEmpty) return;
    final average =
        reviews.map((review) => review.rating).reduce((a, b) => a + b) /
            reviews.length;
    final professional = _professionals.firstWhere(
      (item) => item.id == professionalId,
    );
    _replaceProfessional(
      professional.copyWith(rating: double.parse(average.toStringAsFixed(1))),
    );
  }

  void _seed() {
    final now = DateTime(2024, 3, 12);
    final customer = User(
      id: 'u-customer',
      fullName: 'Hannington Gasasira',
      email: 'hannington@fixrwanda.rw',
      phoneNumber: '+250788123456',
      role: UserRole.customer,
      address: 'KN 5 Ave, Kacyiru',
      createdAt: now,
    );
    final admin = User(
      id: 'u-admin',
      fullName: 'FixRwanda Admin',
      email: 'admin@fixrwanda.rw',
      phoneNumber: '+250788000111',
      role: UserRole.admin,
      createdAt: now,
    );
    _accounts[customer.id] =
        StoredAccount(user: customer, password: 'rwanda123');
    _accounts[admin.id] = StoredAccount(user: admin, password: 'admin123');

    final names = [
      ('Jean Bosco', 'Electrical Installation', 25000, 4.8, 64, 'Kacyiru'),
      ('Aline Uwase', 'Plumbing', 20000, 4.7, 51, 'Nyamirambo'),
      ('Claudine Mukamana', 'House Cleaning', 15000, 4.9, 88, 'Kimironko'),
      ('Eric Niyonsenga', 'Appliance Repair', 18000, 4.6, 39, 'Remera'),
      ('Diane Ingabire', 'Computer & IT Support', 22000, 4.8, 47, 'Kacyiru'),
      ('Patrick Habimana', 'Car Repair', 30000, 4.5, 22, 'Gikondo'),
      ('Sandrine Iradukunda', 'Painting', 18000, 4.7, 33, 'Nyarugenge'),
      ('Emmanuel Ndayisaba', 'Construction', 45000, 4.6, 28, 'Gikondo'),
      ('Chantal Uwimana', 'Hair Styling', 12000, 4.9, 71, 'Remera'),
      ('Nadia Umuhoza', 'Beauty Services', 14000, 4.8, 54, 'Kimironko'),
      ('Isaac Mugisha', 'Electrical Installation', 21000, 4.4, 18, 'Nyarugenge'),
      ('Keza Mutoni', 'House Cleaning', 13000, 4.5, 26, 'Nyamirambo'),
    ];

    for (var i = 0; i < names.length; i++) {
      final item = names[i];
      final pending = item.$1 == 'Patrick Habimana';
      final rejected = item.$1 == 'Isaac Mugisha';
      final overall = pending
          ? VerificationStatus.pending
          : rejected
              ? VerificationStatus.rejected
              : VerificationStatus.verified;
      final phoneStatus = pending
          ? VerificationStatus.verified
          : rejected
              ? VerificationStatus.verified
              : VerificationStatus.verified;
      final idStatus = pending
          ? VerificationStatus.verified
          : rejected
              ? VerificationStatus.rejected
              : VerificationStatus.verified;
      final tvetStatus = pending
          ? VerificationStatus.pending
          : rejected
              ? VerificationStatus.verified
              : VerificationStatus.verified;
      final professional = Professional(
        id: 'pro-$i',
        name: item.$1,
        imageUrl: '',
        category: item.$2,
        description:
            '${item.$1} provides ${item.$2.toLowerCase()} across Kigali with on-site visits.',
        location: 'Kigali',
        startingPrice: item.$3,
        rating: item.$4,
        completedJobs: item.$5,
        phoneVerified: phoneStatus == VerificationStatus.verified,
        idVerified: idStatus == VerificationStatus.verified,
        certificateVerified: tvetStatus == VerificationStatus.verified,
        verificationStatus: overall,
        phoneVerificationStatus: phoneStatus,
        idVerificationStatus: idStatus,
        tvetVerificationStatus: tvetStatus,
        sector: item.$6,
      );
      _professionals.add(professional);
      _services.addAll(
        servicesFor(professional.id, professional.category, professional.startingPrice),
      );
    }

    _bookings.addAll([
      Booking(
        id: 'b-seed-1',
        customerId: customer.id,
        professionalId: 'pro-1',
        serviceId: 'pro-1-s0',
        serviceName: 'Leak repair',
        professionalName: 'Aline Uwase',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledTime: '10:00',
        customerAddress: 'KN 5 Ave, Kacyiru',
        servicePrice: 20000,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        district: 'Kigali',
        sector: 'Kacyiru',
      ),
      Booking(
        id: 'b-seed-2',
        customerId: customer.id,
        professionalId: 'pro-2',
        serviceId: 'pro-2-s0',
        serviceName: 'Home deep clean',
        professionalName: 'Claudine Mukamana',
        scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
        scheduledTime: '09:00',
        customerAddress: 'KG 9 Ave, Kimironko',
        servicePrice: 15000,
        status: BookingStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        district: 'Kigali',
        sector: 'Kimironko',
      ),
    ]);
  }
}
