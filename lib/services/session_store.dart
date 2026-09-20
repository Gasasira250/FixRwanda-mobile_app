import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/professional.dart';

class SessionStore {
  static const _customerKey = 'fixrwanda.session.customer';
  static const _tokenKey = 'fixrwanda.session.token';
  static const _identifierKey = 'fixrwanda.session.last_identifier';
  static const _paymentKey = 'fixrwanda.session.payment';
  static const _locationsKey = 'fixrwanda.session.locations';

  Future<void> saveSession({
    required Customer customer,
    String? token,
    required PaymentMethod paymentMethod,
    required List<String> savedLocations,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = token ?? customer.token;
    await prefs.setString(
      _customerKey,
      jsonEncode({
        'id': customer.id,
        'name': customer.name,
        'identifier': customer.identifier,
        'role': customer.role,
        'token': sessionToken,
      }),
    );
    if (sessionToken != null && sessionToken.isNotEmpty) {
      await prefs.setString(_tokenKey, sessionToken);
    }
    await prefs.setString(_identifierKey, customer.identifier);
    await prefs.setString(_paymentKey, paymentMethod.name);
    await prefs.setStringList(_locationsKey, savedLocations);
  }

  Future<Customer?> loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customerKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final token = prefs.getString(_tokenKey) ?? map['token'] as String?;
      if (map['id'] == null || map['name'] == null) return null;
      return Customer.fromJson({...map, 'token': token});
    } catch (_) {
      return null;
    }
  }

  Future<String?> lastIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_identifierKey);
  }

  Future<PaymentMethod?> loadPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_paymentKey);
    if (name == null) return null;
    for (final method in PaymentMethod.values) {
      if (method.name == name) return method;
    }
    return null;
  }

  Future<List<String>?> loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_locationsKey);
  }

  Future<void> clearSession({bool keepIdentifier = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_identifierKey);
    await prefs.remove(_customerKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_paymentKey);
    await prefs.remove(_locationsKey);
    if (!keepIdentifier) {
      await prefs.remove(_identifierKey);
    } else if (last != null) {
      await prefs.setString(_identifierKey, last);
    }
  }
}
