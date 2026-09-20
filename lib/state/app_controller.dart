import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/professional.dart';
import '../services/api_client.dart';
import '../services/demo_catalog.dart';
import '../services/session_store.dart';

class FixRwandaScope extends InheritedNotifier<AppController> {
  const FixRwandaScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FixRwandaScope>();
    assert(scope != null, 'FixRwandaScope not found');
    return scope!.notifier!;
  }
}

class AppController extends ChangeNotifier {
  AppController({ApiClient? api, SessionStore? session})
    : api = api ?? ApiClient(),
      _session = session ?? SessionStore();

  final ApiClient api;
  final SessionStore _session;

  Customer? customer;
  List<Booking> bookings = const [];
  PaymentMethod preferredPaymentMethod = PaymentMethod.mtnMomo;
  List<String> savedLocations = const [
    'Kigali, Nyarugenge',
    'Kigali, Gasabo',
  ];
  String? rememberedIdentifier;
  bool busy = false;
  String? error;

  bool get isSignedIn => customer != null;
  bool get online => api.online;

  Future<void> restoreSession() async {
    rememberedIdentifier = await _session.lastIdentifier();
    final saved = await _session.loadCustomer();
    if (saved == null) {
      notifyListeners();
      return;
    }
    customer = saved;
    api.token = saved.token;
    preferredPaymentMethod =
        await _session.loadPaymentMethod() ?? preferredPaymentMethod;
    savedLocations = await _session.loadLocations() ?? savedLocations;
    notifyListeners();
    try {
      await api.discover();
      await refreshBookings();
    } catch (_) {}
  }

  Future<bool> signIn({
    required String identifier,
    required String password,
  }) async {
    return _run(() async {
      await api.discover();
      final signedIn = await api.login(
        identifier: identifier,
        password: password,
      );
      customer = signedIn.copyWith(token: api.token);
      rememberedIdentifier = customer!.identifier;
      await refreshBookings();
      await _persist();
    });
  }

  Future<bool> createAccount({
    required String name,
    required String identifier,
    required String password,
  }) async {
    return _run(() async {
      await api.discover();
      final created = await api.register(
        name: name,
        identifier: identifier,
        password: password,
      );
      customer = created.copyWith(token: api.token);
      rememberedIdentifier = customer!.identifier;
      await refreshBookings();
      await _persist();
    });
  }

  Future<void> signOut() async {
    customer = null;
    bookings = const [];
    api.token = null;
    await _session.clearSession();
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String identifier,
  }) async {
    final current = customer;
    if (current == null) return;
    customer = current.copyWith(
      name: name.trim(),
      identifier: identifier.trim(),
    );
    rememberedIdentifier = customer!.identifier;
    await _persist();
    notifyListeners();
  }

  Future<void> setPreferredPaymentMethod(PaymentMethod method) async {
    preferredPaymentMethod = method;
    await _persist();
    notifyListeners();
  }

  Future<void> addSavedLocation(String location) async {
    final value = location.trim();
    if (value.isEmpty || savedLocations.contains(value)) return;
    savedLocations = [...savedLocations, value];
    await _persist();
    notifyListeners();
  }

  Future<void> removeSavedLocation(String location) async {
    savedLocations = savedLocations.where((item) => item != location).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> refreshBookings() async {
    bookings = await api.fetchBookings();
    final fromJobs = bookings
        .map((item) => item.location)
        .where((item) => item.trim().isNotEmpty);
    savedLocations = {...savedLocations, ...fromJobs}.toList();
    if (isSignedIn) await _persist();
    notifyListeners();
  }

  Booking? bookingById(String id) {
    for (final booking in bookings) {
      if (booking.id == id) return booking;
    }
    for (final booking in api.catalog.bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  Future<Map<String, dynamic>> requestMoMo({
    required String phoneNumber,
    required int amountRwf,
    required PaymentMethod method,
    String? bookingId,
  }) {
    return api.requestMoMo(
      phoneNumber: phoneNumber,
      amountRwf: amountRwf,
      method: method,
      bookingId: bookingId,
    );
  }

  Future<Booking> payAndConfirm({
    required BookingDraft draft,
    required PaymentMethod method,
  }) async {
    final booking = await api.payAndConfirm(draft: draft, method: method);
    await refreshBookings();
    return bookingById(booking.id) ?? booking;
  }

  Future<CancellationQuote> quoteCancellation(Booking booking) {
    return api.quoteCancellation(booking.id);
  }

  Future<Booking> cancelBooking(String bookingId) async {
    final cancelled = await api.cancelBooking(bookingId);
    await refreshBookings();
    return bookingById(cancelled.id) ?? cancelled;
  }

  Future<void> _persist() async {
    final current = customer;
    if (current == null) return;
    await _session.saveSession(
      customer: current,
      token: api.token ?? current.token,
      paymentMethod: preferredPaymentMethod,
      savedLocations: savedLocations,
    );
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      busy = false;
      notifyListeners();
      return true;
    } catch (err) {
      busy = false;
      error = err is AuthException ? err.message : err.toString();
      notifyListeners();
      return false;
    }
  }
}
