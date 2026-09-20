import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_config.dart';
import '../core/exceptions.dart';
import '../domain/booking_lifecycle.dart';
import '../domain/broadcast_router.dart';
import '../domain/cancellation_policy.dart';
import '../domain/commission_service.dart';
import '../domain/nida.dart';
import '../domain/verification_pipeline.dart';
import '../models/booking.dart';
import '../models/commission.dart';
import '../models/escrow.dart';
import '../models/job_message.dart';
import '../models/payment.dart';
import '../models/professional.dart';
import '../models/provider_verification.dart';
import '../models/review.dart';
import '../models/service.dart';
import '../models/user.dart';
import '../payments/escrow_service.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/professional_repository.dart';
import '../utils/constants.dart';
import '../repositories/review_repository.dart';
import '../repositories/verification_repository.dart';
import '../verification/irembo_audit.dart';
import '../verification/kyc_provider.dart';
import '../verification/trade_cert_audit.dart';
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
        AdminRepository,
        VerificationRepository {
  LocalMarketplaceStore({
    CommissionService? commissionService,
    EscrowService? escrowService,
    IdentityKycClient? kycClient,
    IremboGovAuditClient? iremboAudit,
    TradeCertAuditClient? tradeAudit,
    this._preferences,
  })  : _commissionService = commissionService ?? const CommissionService(),
        _escrow = escrowService ?? buildMockEscrowService(),
        _kyc = kycClient ?? const SmileIdKycClient(),
        _iremboAudit = iremboAudit ?? const MockIremboGovAuditClient(),
        _tradeAudit = tradeAudit ?? const MockTradeCertAuditClient();

  final CommissionService _commissionService;
  final EscrowService _escrow;
  final IdentityKycClient _kyc;
  final IremboGovAuditClient _iremboAudit;
  final TradeCertAuditClient _tradeAudit;
  SharedPreferences? _preferences;

  final Map<String, StoredAccount> _accounts = {};
  final List<Professional> _professionals = [];
  final List<Service> _services = [];
  final List<Booking> _bookings = [];
  final List<Payment> _payments = [];
  final List<Review> _reviews = [];
  final List<CommissionBreakdown> _commissions = [];
  final List<EscrowHold> _escrows = [];
  final List<JobMessage> _messages = [];
  String? _sessionUserId;
  final _random = Random();

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

  List<Service> servicesForCategory(String category) {
    return categoryServices(category);
  }

  Service? serviceById(String id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  List<CommissionBreakdown> get commissions => List.unmodifiable(_commissions);

  EscrowHold? escrowFor(String bookingId) {
    EscrowHold? latest;
    for (final hold in _escrows) {
      if (hold.bookingId == bookingId) latest = hold;
    }
    return latest;
  }

  Professional? professionalForUser(String userId) {
    for (final professional in _professionals) {
      if (professional.userId == userId) return professional;
    }
    return null;
  }

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
    if (role == UserRole.professional) {
      _professionals.add(
        Professional(
          id: 'pro-${user.id}',
          name: user.fullName,
          imageUrl: '',
          category: AppConstants.serviceCategories.first,
          description: '${user.fullName} is awaiting verification.',
          location: 'Kigali',
          startingPrice: 15000,
          rating: 0,
          completedJobs: 0,
          phoneVerified: false,
          idVerified: false,
          certificateVerified: false,
          verificationStatus: VerificationStatus.pending,
          userId: user.id,
          sector: kigaliDistricts.first,
          district: kigaliDistricts.first,
        ),
      );
    }
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
    if (customer.role != UserRole.customer && customer.role != UserRole.admin) {
      throw MarketplaceException('Only customers can request a job.');
    }
    final booking = Booking(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customer.id,
      serviceId: input.serviceId,
      serviceName: input.serviceName,
      category: input.category,
      scheduledDate: input.scheduledDate,
      scheduledTime: input.scheduledTime,
      customerAddress: input.customerAddress,
      servicePrice: input.servicePrice,
      platformFeeRwf: (input.servicePrice * AppConfig.commissionRate).round(),
      paymentState: PaymentState.initiated,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      district: input.district ?? 'Gasabo',
      sector: input.sector,
    );
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<List<Booking>> openBroadcastsForProfessional(String professionalId) async {
    await expireStaleBroadcasts();
    final professional = await getProfessionalById(professionalId);
    if (professional == null || !professional.isBookable) return const [];
    return _bookings.where((booking) {
      return booking.status == BookingStatus.broadcasting &&
          booking.currentOfferIds.contains(professionalId) &&
          booking.district == professional.district &&
          booking.category == professional.category;
    }).toList();
  }

  @override
  Future<List<Booking>> assignedJobsForProfessional(String professionalId) async {
    await expireStaleBroadcasts();
    return _bookings
        .where((booking) => booking.professionalId == professionalId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Payment> payBooking({
    required String bookingId,
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    await initialize();
    if (AppConfig.allowCashPayouts) {
      throw MarketplaceException('Cash payouts are disabled.');
    }
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw MarketplaceException('Booking was not found.');
    }
    if (booking.status != BookingStatus.pending) {
      throw MarketplaceException('This request is no longer awaiting escrow.');
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

    try {
      final hold = await _escrow.hold(
        EscrowRequest(
          bookingId: booking.id,
          amountRwf: booking.servicePrice,
          method: method,
          phoneNumber: phoneNumber,
        ),
      );
      _escrows.add(hold);
      final settled = pendingPayment.copyWith(
        status: PaymentStatus.success,
        transactionReference: hold.providerReference,
      );
      _replacePayment(settled);
      final origin = BroadcastRouter.pointForDistrict(booking.district ?? 'Gasabo');
      final ranked = BroadcastRouter.rankVerified(
        professionals: _professionals,
        district: booking.district ?? 'Gasabo',
        category: booking.category,
        origin: origin,
      );
      final offerIds = BroadcastRouter.nextOfferIds(
        ranked: ranked,
        alreadyOffered: const [],
        take: BroadcastRouter.initialOfferCount,
      );
      final broadcasting = booking.copyWith(
        status: BookingLifecycle.transition(
          booking.status,
          BookingStatus.broadcasting,
        ),
        paymentId: settled.id,
        escrowId: hold.id,
        broadcastExpiresAt: DateTime.now().add(AppConfig.broadcastTimeout),
        broadcastRound: 1,
        currentOfferIds: offerIds,
        offeredProviderIds: offerIds,
        paymentState: PaymentState.heldInEscrow,
        platformFeeRwf: (booking.servicePrice * AppConfig.commissionRate).round(),
      );
      _replaceBooking(broadcasting);
      return settled;
    } catch (_) {
      final failed = pendingPayment.copyWith(status: PaymentStatus.failed);
      _replacePayment(failed);
      return failed;
    }
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
    await _refundEscrow(booking, feeRwf: quote.cancellationFeeRwf);
    final cancelled = booking.copyWith(
      status: BookingStatus.cancelled,
      cancellationFeeRwf: quote.cancellationFeeRwf,
      refundAmountRwf: quote.refundAmountRwf,
      cancelledAt: DateTime.now(),
      paymentState: PaymentState.refunded,
    );
    _replaceBooking(cancelled);
    return cancelled;
  }

  @override
  Future<Booking> updateStatus(String bookingId, BookingStatus status) {
    return switch (status) {
      BookingStatus.enRoute => startTravel(bookingId),
      BookingStatus.arrived => markArrived(bookingId),
      BookingStatus.inProgress =>
        startJob(bookingId, photoRef: 'evidence://auto'),
      _ => Future.error(
          MarketplaceException('Use the job actions instead of a free status jump.'),
        ),
    };
  }

  @override
  Future<Booking> acceptJob(String bookingId) async {
    await expireStaleBroadcasts();
    final professional = _requireVerifiedProfessional();
    final booking = await _requireBooking(bookingId);
    if (booking.status != BookingStatus.broadcasting) {
      throw MarketplaceException('This job is no longer open.');
    }
    if (!booking.currentOfferIds.contains(professional.id)) {
      throw MarketplaceException('This job was offered to closer technicians first.');
    }
    if (booking.district != professional.district) {
      throw MarketplaceException('This job is outside your district.');
    }
    BookingLifecycle.transition(booking.status, BookingStatus.accepted);
    final accepted = booking.copyWith(
      status: BookingStatus.accepted,
      professionalId: professional.id,
      professionalName: professional.name,
    );
    _replaceBooking(accepted);
    return accepted;
  }

  @override
  Future<Booking> startTravel(String bookingId) async {
    final booking = await _requireAssignedJob(bookingId);
    BookingLifecycle.transition(booking.status, BookingStatus.enRoute);
    final updated = booking.copyWith(
      status: BookingStatus.enRoute,
      providerLatitude: -1.9441,
      providerLongitude: 30.0619,
      lastLocationAt: DateTime.now(),
    );
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<Booking> markArrived(String bookingId) async {
    final booking = await _requireAssignedJob(bookingId);
    BookingLifecycle.transition(booking.status, BookingStatus.arrived);
    final updated = booking.copyWith(status: BookingStatus.arrived);
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<Booking> startJob(
    String bookingId, {
    required String photoRef,
  }) async {
    final booking = await _requireAssignedJob(bookingId);
    if (photoRef.trim().isEmpty) {
      throw MarketplaceException('Upload an arrival photo before starting the job.');
    }
    BookingLifecycle.transition(booking.status, BookingStatus.inProgress);
    final otp = (1000 + _random.nextInt(9000)).toString();
    final updated = booking.copyWith(
      status: BookingStatus.inProgress,
      startJobPhotoRef: photoRef.trim(),
      startedAt: DateTime.now(),
      completionOtp: otp,
    );
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<Booking> markWorkFinished(String bookingId, {String otp = ''}) async {
    final booking = await _requireAssignedJob(bookingId);
    if (booking.startJobPhotoRef == null) {
      throw MarketplaceException('Start the job with a photo first.');
    }
    if (booking.afterPhotoUrl == null) {
      throw MarketplaceException('Upload an after photo before payout.');
    }
    if (booking.completionOtp == null) {
      throw MarketplaceException('The client confirmation code is not ready.');
    }
    if (otp.trim() != booking.completionOtp) {
      throw MarketplaceException(
        'Enter the 4-digit code from the client screen to release payout.',
      );
    }
    BookingLifecycle.transition(booking.status, BookingStatus.completed);
    await _releaseEscrow(booking);
    final completed = booking.copyWith(
      status: BookingStatus.completed,
      paymentState: PaymentState.disbursedToProvider,
    );
    _replaceBooking(completed);
    final professional = await getProfessionalById(booking.professionalId);
    if (professional != null) {
      _replaceProfessional(
        professional.copyWith(completedJobs: professional.completedJobs + 1),
      );
    }
    return completed;
  }

  @override
  Future<Booking> confirmCompletionWithOtp(String bookingId, String otp) {
    return markWorkFinished(bookingId, otp: otp);
  }

  @override
  Future<Booking> uploadAfterPhoto(String bookingId, {required String photoRef}) async {
    final booking = await _requireAssignedJob(bookingId);
    if (booking.status != BookingStatus.inProgress) {
      throw MarketplaceException('After photos are taken while the job is in progress.');
    }
    if (photoRef.trim().isEmpty) {
      throw MarketplaceException('Upload an after photo.');
    }
    final updated = booking.copyWith(afterPhotoUrl: photoRef.trim());
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<Booking> openDispute(String bookingId, {required String reason}) async {
    await initialize();
    final user = currentUserOrThrow();
    final booking = await _requireBooking(bookingId);
    if (user.id != booking.customerId && user.role != UserRole.admin) {
      throw MarketplaceException('Only the client can open a dispute.');
    }
    if (booking.paymentState == PaymentState.disbursedToProvider) {
      throw MarketplaceException('Payout already left escrow.');
    }
    if (reason.trim().length < 8) {
      throw MarketplaceException('Explain the dispute in at least 8 characters.');
    }
    BookingLifecycle.transition(booking.status, BookingStatus.disputed);
    final updated = booking.copyWith(
      status: BookingStatus.disputed,
      disputeReason: reason.trim(),
    );
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<Booking> adminRefund(String bookingId) async {
    _requireAdmin();
    final booking = await _requireBooking(bookingId);
    BookingLifecycle.transition(booking.status, BookingStatus.cancelled);
    await _refundEscrow(booking);
    final updated = booking.copyWith(
      status: BookingStatus.cancelled,
      paymentState: PaymentState.refunded,
      refundAmountRwf: booking.servicePrice,
      cancelledAt: DateTime.now(),
    );
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<Booking> adminPayout(String bookingId) async {
    _requireAdmin();
    final booking = await _requireBooking(bookingId);
    BookingLifecycle.transition(booking.status, BookingStatus.completed);
    await _releaseEscrow(booking);
    final updated = booking.copyWith(
      status: BookingStatus.completed,
      paymentState: PaymentState.disbursedToProvider,
    );
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<List<Booking>> disputedBookings() async {
    await initialize();
    return _bookings
        .where((booking) => booking.status == BookingStatus.disputed)
        .toList();
  }

  @override
  Future<JobMessage> sendJobMessage({
    required String bookingId,
    required String body,
  }) async {
    await initialize();
    final user = currentUserOrThrow();
    final booking = await _requireBooking(bookingId);
    if (body.trim().isEmpty) {
      throw MarketplaceException('Write a message first.');
    }
    if (user.id != booking.customerId &&
        user.role != UserRole.admin &&
        professionalForUser(user.id)?.id != booking.professionalId) {
      throw MarketplaceException('You cannot message this job.');
    }
    final message = JobMessage(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: booking.id,
      senderId: user.id,
      senderName: user.fullName,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    _messages.add(message);
    return message;
  }

  @override
  List<JobMessage> messagesFor(String bookingId) {
    return _messages.where((item) => item.bookingId == bookingId).toList();
  }

  void _requireAdmin() {
    final user = currentUserOrThrow();
    if (user.role != UserRole.admin) {
      throw MarketplaceException('Admin access is required.');
    }
  }

  @override
  Future<Booking> pushLocation({
    required String bookingId,
    required double latitude,
    required double longitude,
  }) async {
    final booking = await _requireAssignedJob(bookingId);
    if (booking.status != BookingStatus.enRoute &&
        booking.status != BookingStatus.arrived &&
        booking.status != BookingStatus.inProgress) {
      throw MarketplaceException('Location is only shared after the job is accepted.');
    }
    final updated = booking.copyWith(
      providerLatitude: latitude,
      providerLongitude: longitude,
      lastLocationAt: DateTime.now(),
    );
    _replaceBooking(updated);
    return updated;
  }

  @override
  Future<int> expireStaleBroadcasts({DateTime? now}) async {
    await initialize();
    final clock = now ?? DateTime.now();
    var expired = 0;
    for (final booking in List<Booking>.from(_bookings)) {
      if (booking.status != BookingStatus.broadcasting) continue;
      final deadline = booking.broadcastExpiresAt;
      if (deadline == null || !clock.isAfter(deadline)) continue;
      final origin = BroadcastRouter.pointForDistrict(booking.district ?? 'Gasabo');
      final ranked = BroadcastRouter.rankVerified(
        professionals: _professionals,
        district: booking.district ?? 'Gasabo',
        category: booking.category,
        origin: origin,
      );
      final nextIds = BroadcastRouter.nextOfferIds(
        ranked: ranked,
        alreadyOffered: booking.offeredProviderIds,
        take: BroadcastRouter.rerouteOfferCount,
      );
      if (nextIds.isEmpty) {
        BookingLifecycle.transition(booking.status, BookingStatus.expired);
        await _refundEscrow(booking);
        _replaceBooking(
          booking.copyWith(
            status: BookingStatus.expired,
            refundAmountRwf: booking.servicePrice,
            currentOfferIds: const [],
            paymentState: PaymentState.refunded,
          ),
        );
        expired += 1;
        continue;
      }
      _replaceBooking(
        booking.copyWith(
          currentOfferIds: nextIds,
          offeredProviderIds: [...booking.offeredProviderIds, ...nextIds],
          broadcastExpiresAt: clock.add(AppConfig.broadcastTimeout),
          broadcastRound: booking.broadcastRound + 1,
        ),
      );
    }
    return expired;
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
    if (status == VerificationStatus.verified) {
      final evaluated = VerificationPipeline.evaluate(professional.pipeline);
      if (!evaluated.kigaliGreenBadge) {
        throw MarketplaceException(
          'NIDA KYC, Irembo good conduct, and a TVET/IPRC or RDB document must pass before the Kigali Green Badge can be issued.',
        );
      }
      final updated = professional.applyPipeline(evaluated);
      _replaceProfessional(updated);
      return updated;
    }
    final updated = professional.copyWith(
      verificationStatus: status,
      kigaliGreenBadge: false,
    );
    _replaceProfessional(updated);
    return updated;
  }

  @override
  Future<Professional> submitNidaKyc({
    required String nidaNumber,
    required String selfieRef,
  }) async {
    await initialize();
    final professional = _requireOwnProfessional();
    final result = await _kyc.verifyNida(
      nidaNumber: nidaNumber,
      selfieRef: selfieRef,
    );
    final next = professional.pipeline.copyWith(
      nidaNumber: NidaNumber.normalize(nidaNumber),
      livenessSelfieRef: selfieRef.trim(),
      smileJobId: result.jobId,
      nidaStatus: result.verified
          ? VerificationStatus.verified
          : VerificationStatus.rejected,
      livenessStatus: result.verified
          ? VerificationStatus.verified
          : VerificationStatus.rejected,
      rejectionReason: result.reason,
      clearRejection: result.verified,
    );
    return _commitPipeline(professional, next);
  }

  @override
  Future<Professional> submitIremboCertificate({
    required String documentRef,
  }) async {
    await initialize();
    final professional = _requireOwnProfessional();
    final result = await _iremboAudit.auditGoodConduct(
      providerId: professional.id,
      documentRef: documentRef,
    );
    final next = professional.pipeline.copyWith(
      iremboCertUrl: result.certificateUrl,
      iremboStatus: result.verified
          ? VerificationStatus.verified
          : VerificationStatus.rejected,
      rejectionReason: result.reason,
      clearRejection: result.verified,
    );
    return _commitPipeline(professional, next);
  }

  @override
  Future<Professional> submitTradeCertificate({
    required TradeCertificateKind kind,
    required String documentRef,
  }) async {
    await initialize();
    final professional = _requireOwnProfessional();
    final result = await _tradeAudit.audit(
      providerId: professional.id,
      kind: kind,
      documentRef: documentRef,
    );
    final next = professional.pipeline.copyWith(
      tradeKind: kind,
      tradeCertUrl: result.certificateUrl,
      tradeStatus: result.verified
          ? VerificationStatus.verified
          : VerificationStatus.rejected,
      rejectionReason: result.reason,
      clearRejection: result.verified,
    );
    return _commitPipeline(professional, next);
  }

  @override
  Map<String, dynamic> verificationFlag(String professionalId) {
    Professional? professional;
    for (final item in _professionals) {
      if (item.id == professionalId) professional = item;
    }
    if (professional == null) {
      throw MarketplaceException('Professional was not found.');
    }
    return professional.verificationFlag;
  }

  Professional _commitPipeline(
    Professional professional,
    ProviderVerification next,
  ) {
    final updated = professional.applyPipeline(
      VerificationPipeline.evaluate(next),
    );
    _replaceProfessional(updated);
    return updated;
  }

  Professional _requireOwnProfessional() {
    final user = currentUserOrThrow();
    final professional = professionalForUser(user.id);
    if (professional == null) {
      throw MarketplaceException(
        'This account is not linked to a professional profile.',
      );
    }
    return professional;
  }

  Future<Booking> _requireBooking(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw MarketplaceException('Booking was not found.');
    }
    return booking;
  }

  Professional _requireVerifiedProfessional() {
    final user = currentUserOrThrow();
    final professional = professionalForUser(user.id);
    if (professional == null) {
      throw MarketplaceException('This account is not linked to a professional profile.');
    }
    if (!professional.isBookable) {
      throw MarketplaceException(
        'Only verified professionals with a Kigali Green Badge can accept jobs.',
      );
    }
    return professional;
  }

  Future<Booking> _requireAssignedJob(String bookingId) async {
    final professional = _requireVerifiedProfessional();
    final booking = await _requireBooking(bookingId);
    if (booking.professionalId != professional.id) {
      throw MarketplaceException('This job is assigned to another professional.');
    }
    return booking;
  }

  Future<void> _refundEscrow(Booking booking, {int feeRwf = 0}) async {
    final hold = escrowFor(booking.id);
    if (hold == null || hold.status != EscrowStatus.held) return;
    final refunded = await _escrow.refundToClient(hold, feeRwf: feeRwf);
    _replaceEscrow(refunded);
  }

  Future<void> _releaseEscrow(Booking booking) async {
    final hold = escrowFor(booking.id);
    if (hold == null || hold.status != EscrowStatus.held) {
      throw MarketplaceException('Escrow is not holding funds for this job.');
    }
    final released = await _escrow.releaseToProvider(hold);
    _replaceEscrow(released);
    _commissions.add(
      _commissionService.calculate(booking.servicePrice),
    );
  }

  void _replaceEscrow(EscrowHold hold) {
    final index = _escrows.indexWhere((item) => item.id == hold.id);
    if (index >= 0) {
      _escrows[index] = hold;
    } else {
      _escrows.add(hold);
    }
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
    final provider = User(
      id: 'u-provider',
      fullName: 'Jean Bosco',
      email: 'jean@fixrwanda.rw',
      phoneNumber: '+250788555111',
      role: UserRole.professional,
      address: 'Kacyiru',
      createdAt: now,
    );
    _accounts[provider.id] =
        StoredAccount(user: provider, password: 'rwanda123');

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
      ('Yves Habimana', 'Electrical Installation', 24000, 4.3, 12, 'Kimironko'),
      ('Grace Mukamana', 'Electrical Installation', 23000, 4.2, 9, 'Remera'),
      ('Alain Niyonzima', 'Electrical Installation', 22000, 4.1, 7, 'Kacyiru'),
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
        userId: i == 0 ? 'u-provider' : null,
        sector: item.$6,
        district: BroadcastRouter.districtForSector(item.$6),
        latitude: BroadcastRouter.pointForDistrict(
              BroadcastRouter.districtForSector(item.$6),
            ).lat +
            (i * 0.003),
        longitude: BroadcastRouter.pointForDistrict(
              BroadcastRouter.districtForSector(item.$6),
            ).lng +
            (i * 0.002),
      );
      final seeded = overall == VerificationStatus.verified
          ? professional.applyPipeline(
              ProviderVerification(
                providerId: professional.id,
                overallStatus: VerificationStatus.verified,
                kigaliGreenBadge: true,
                nidaStatus: VerificationStatus.verified,
                livenessStatus: VerificationStatus.verified,
                iremboStatus: VerificationStatus.verified,
                tradeStatus: VerificationStatus.verified,
                nidaNumber: NidaNumber.seed(i),
                iremboCertUrl: 'https://s3.amazonaws.com/certs/irembo_$i.pdf',
                tradeCertUrl: 'https://s3.amazonaws.com/certs/tvet_$i.pdf',
                tradeKind: TradeCertificateKind.tvetIprc,
                smileJobId: 'smile-job-$i',
                livenessSelfieRef: 'liveness-$i',
              ),
            )
          : professional;
      _professionals.add(seeded);
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
        category: 'Plumbing',
        professionalName: 'Aline Uwase',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledTime: '10:00',
        customerAddress: 'KN 5 Ave, Kacyiru',
        servicePrice: 20000,
        status: BookingStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        district: 'Gasabo',
        sector: 'Kacyiru',
      ),
      Booking(
        id: 'b-seed-2',
        customerId: customer.id,
        professionalId: 'pro-2',
        serviceId: 'pro-2-s0',
        serviceName: 'Home deep clean',
        category: 'House Cleaning',
        professionalName: 'Claudine Mukamana',
        scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
        scheduledTime: '09:00',
        customerAddress: 'KG 9 Ave, Kimironko',
        servicePrice: 15000,
        status: BookingStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        district: 'Gasabo',
        sector: 'Kimironko',
        paymentState: PaymentState.disbursedToProvider,
      ),
      Booking(
        id: 'b-seed-3',
        customerId: customer.id,
        professionalId: 'pro-1',
        serviceId: 'pro-1-s0',
        serviceName: 'Emergency leak',
        category: 'Plumbing',
        professionalName: 'Aline Uwase',
        scheduledDate: DateTime.now().subtract(const Duration(hours: 6)),
        scheduledTime: '14:00',
        customerAddress: 'KN 3 Rd, Kacyiru',
        servicePrice: 20000,
        platformFeeRwf: 3000,
        status: BookingStatus.disputed,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        district: 'Gasabo',
        sector: 'Kacyiru',
        paymentState: PaymentState.heldInEscrow,
        startJobPhotoRef: 'before-seed-3',
        afterPhotoUrl: 'after-seed-3',
        completionOtp: '4821',
        disputeReason: 'Water still leaks under the sink after the visit.',
      ),
    ]);
    _escrows.add(
      EscrowHold(
        id: 'escrow-seed-3',
        bookingId: 'b-seed-3',
        amountRwf: 20000,
        status: EscrowStatus.held,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        marketplaceFeeRwf: 3000,
      ),
    );
    _messages.addAll([
      JobMessage(
        id: 'm-seed-1',
        bookingId: 'b-seed-3',
        senderId: customer.id,
        senderName: customer.fullName,
        body: 'The cabinet floor is still wet.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      JobMessage(
        id: 'm-seed-2',
        bookingId: 'b-seed-3',
        senderId: 'u-provider',
        senderName: 'Aline Uwase',
        body: 'I replaced the trap. Please send a photo of the leak.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);
  }
}
