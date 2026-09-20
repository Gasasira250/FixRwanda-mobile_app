import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchExternal(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Future<bool> makePhoneCall(String phoneNumber) {
  final digits = phoneNumber.replaceAll(RegExp(r'\s'), '');
  return launchExternal(Uri(scheme: 'tel', path: digits));
}

Future<bool> sendSms(String phoneNumber, {String? body}) {
  final digits = phoneNumber.replaceAll(RegExp(r'\s'), '');
  return launchExternal(
    Uri(
      scheme: 'sms',
      path: digits,
      queryParameters: body == null ? null : {'body': body},
    ),
  );
}

Future<bool> openMaps({String? query, double? latitude, double? longitude}) {
  if (latitude != null && longitude != null) {
    return launchExternal(
      Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      ),
    );
  }
  final q = (query ?? 'Kigali').trim();
  return launchExternal(
    Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
    ),
  );
}

String rwandaContactFor(String seed, {bool airtel = false}) {
  final n = seed.hashCode.abs() % 10000000;
  final prefix = airtel ? '073' : '078';
  return '$prefix${n.toString().padLeft(7, '0').substring(0, 7)}';
}

Future<void> showLaunchResult(
  BuildContext context, {
  required bool ok,
  required String fallback,
}) async {
  if (ok || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fallback)));
}
