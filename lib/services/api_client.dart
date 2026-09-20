import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/booking.dart';
import '../models/professional.dart';
import 'demo_catalog.dart';

/// REST client for FixRwanda.
///
/// Production path: Flutter → Express API → PostgreSQL.
/// If the API is down, the same methods fall back to [DemoCatalog].
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    DemoCatalog? catalog,
  }) : _http = httpClient ?? http.Client(),
       catalog = catalog ?? DemoCatalog() {
    this.baseUrl = baseUrl ?? resolveBaseUrl();
  }

  /// Android emulator reaches the host at 10.0.2.2.
  /// A physical phone uses LAN_IP (default 192.168.1.9) or API_BASE.
  /// Override with --dart-define=API_BASE=http://YOUR_LAN_IP:4000/api
  static String resolveBaseUrl() {
    const fromEnv = String.fromEnvironment('API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api';
    }
    return 'http://127.0.0.1:4000/api';
  }

  static List<String> candidateBaseUrls() {
    const fromEnv = String.fromEnvironment('API_BASE');
    const lan = String.fromEnvironment('LAN_IP', defaultValue: '192.168.1.9');
    final urls = <String>[];
    if (fromEnv.isNotEmpty) urls.add(fromEnv);
    if (defaultTargetPlatform == TargetPlatform.android) {
      urls.add('http://10.0.2.2:4000/api');
      urls.add('http://$lan:4000/api');
    } else {
      urls.add('http://127.0.0.1:4000/api');
    }
    return urls.toSet().toList();
  }

  Future<void> discover() async {
    for (final url in candidateBaseUrls()) {
      try {
        final origin = url.replaceFirst(RegExp(r'/api/?$'), '');
        final response = await _http
            .get(Uri.parse('$origin/health'))
            .timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          baseUrl = url;
          online = true;
          return;
        }
      } catch (_) {}
    }
  }

  static String get defaultBaseUrl => resolveBaseUrl();

  final http.Client _http;
  late String baseUrl;
  final DemoCatalog catalog;

  bool online = false;
  String? token;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<T> _tryOnline<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      online = true;
      return result;
    } catch (error) {
      if (error is AuthException) rethrow;
      online = false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _json(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    String message = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
    } catch (_) {
      if (response.statusCode == 404) {
        message =
            'Could not reach the login service. Restart the FixRwanda API and try again.';
      } else if (response.statusCode == 401) {
        message = 'Invalid email or password';
      }
    }
    throw AuthException(message);
  }

  Future<http.Response> _postAuth(
    List<String> paths,
    Map<String, dynamic> body,
  ) async {
    http.Response? last;
    for (final path in paths) {
      last = await _http
          .post(
            _uri(path),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));
      if (last.statusCode != 404) return last;
    }
    return last!;
  }

  Future<Customer> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final body = await _tryOnline(() async {
        final response = await _postAuth(
          ['/login', '/auth/login'],
          {
            'identifier': identifier,
            'email': identifier,
            'password': password,
          },
        );
        return _json(response);
      });
      final customer = Customer.fromJson(body['user'] as Map<String, dynamic>);
      token = body['token'] as String? ?? customer.token;
      return customer;
    } catch (error) {
      if (error is AuthException && online) rethrow;
      final customer = catalog.login(
        identifier: identifier,
        password: password,
      );
      token = customer.token;
      online = false;
      return customer;
    }
  }

  Future<Customer> register({
    required String name,
    required String identifier,
    required String password,
  }) async {
    try {
      final body = await _tryOnline(() async {
        final response = await _postAuth(
          ['/signup', '/auth/register'],
          {
            'name': name,
            'identifier': identifier,
            'email': identifier,
            'password': password,
          },
        );
        return _json(response);
      });
      final customer = Customer.fromJson(body['user'] as Map<String, dynamic>);
      token = body['token'] as String? ?? customer.token;
      return customer;
    } catch (error) {
      if (error is AuthException && online) rethrow;
      final customer = catalog.register(
        name: name,
        identifier: identifier,
        password: password,
      );
      token = customer.token;
      online = false;
      return customer;
    }
  }

  Future<List<ServiceCategory>> fetchCategories() async {
    try {
      final body = await _tryOnline(() async {
        final response = await _http
            .get(_uri('/services'), headers: _headers)
            .timeout(const Duration(seconds: 4));
        return _json(response);
      });
      return (body['categories'] as List<dynamic>)
          .map((item) => ServiceCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      online = false;
      return DemoCatalog.categories;
    }
  }

  Future<List<Professional>> fetchProfessionals({
    String? trade,
    String? query,
  }) async {
    try {
      final body = await _tryOnline(() async {
        final response = await _http
            .get(
              _uri('/professionals', {
                if (trade != null && trade.isNotEmpty) 'trade': trade,
                if (query != null && query.isNotEmpty) 'q': query,
              }),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 4));
        return _json(response);
      });
      return (body['professionals'] as List<dynamic>)
          .map((item) => Professional.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      online = false;
      return catalog.search(trade: trade, query: query);
    }
  }

  Future<Map<String, dynamic>> requestMoMo({
    required String phoneNumber,
    required int amountRwf,
    required PaymentMethod method,
    String? bookingId,
  }) async {
    try {
      return await _tryOnline(() async {
        final response = await _http
            .post(
              _uri('/payments/momo'),
              headers: _headers,
              body: jsonEncode({
                'phoneNumber': phoneNumber,
                'amount': amountRwf,
                'method': method.name,
                'bookingId': ?bookingId,
              }),
            )
            .timeout(const Duration(seconds: 8));
        return _json(response);
      });
    } catch (error) {
      if (error is AuthException && online) rethrow;
      online = false;
      final prefix = method == PaymentMethod.airtelMoney ? 'AIR' : 'MOM';
      return {
        'success': true,
        'status': 'Pending Processing',
        'message':
            'USSD prompt sent to $phoneNumber for $amountRwf RWF.',
        'providerReference':
            '$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'phoneNumber': phoneNumber,
        'amount': amountRwf,
        'method': method.name,
      };
    }
  }

  Future<List<Booking>> fetchBookings() async {
    try {
      final body = await _tryOnline(() async {
        final response = await _http
            .get(_uri('/bookings'), headers: _headers)
            .timeout(const Duration(seconds: 4));
        return _json(response);
      });
      return (body['bookings'] as List<dynamic>)
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      online = false;
      return List.unmodifiable(catalog.bookings);
    }
  }

  Future<Booking> payAndConfirm({
    required BookingDraft draft,
    required PaymentMethod method,
  }) async {
    try {
      final body = await _tryOnline(() async {
        final response = await _http
            .post(
              _uri('/bookings'),
              headers: _headers,
              body: jsonEncode(draft.toJson(method)),
            )
            .timeout(const Duration(seconds: 8));
        return _json(response);
      });
      return Booking.fromJson(body['booking'] as Map<String, dynamic>);
    } catch (error) {
      if (error is AuthException && online) rethrow;
      online = false;
      return catalog.payAndConfirm(draft: draft, method: method);
    }
  }

  Future<CancellationQuote> quoteCancellation(String bookingId) async {
    try {
      final body = await _tryOnline(() async {
        final response = await _http
            .get(_uri('/bookings/$bookingId/refund-quote'), headers: _headers)
            .timeout(const Duration(seconds: 4));
        return _json(response);
      });
      return CancellationQuote.fromJson(body['quote'] as Map<String, dynamic>);
    } catch (_) {
      online = false;
      return catalog.quote(bookingId);
    }
  }

  Future<Booking> cancelBooking(String bookingId) async {
    try {
      final body = await _tryOnline(() async {
        final response = await _http
            .post(_uri('/bookings/$bookingId/cancel'), headers: _headers)
            .timeout(const Duration(seconds: 6));
        return _json(response);
      });
      return Booking.fromJson(body['booking'] as Map<String, dynamic>);
    } catch (error) {
      if (error is AuthException && online) rethrow;
      online = false;
      return catalog.cancel(bookingId);
    }
  }

  Future<Booking> advanceBooking(String bookingId) async {
    try {
      final body = await _tryOnline(() async {
        final response = await _http
            .post(_uri('/bookings/$bookingId/advance'), headers: _headers)
            .timeout(const Duration(seconds: 6));
        return _json(response);
      });
      return Booking.fromJson(body['booking'] as Map<String, dynamic>);
    } catch (error) {
      if (error is AuthException && online) rethrow;
      online = false;
      return catalog.advance(bookingId);
    }
  }
}
