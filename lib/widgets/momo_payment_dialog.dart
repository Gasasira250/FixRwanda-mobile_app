import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

Future<String?> showMoMoPaymentDialog(
  BuildContext context, {
  required int amountRwf,
  required String methodLabel,
}) {
  final phone = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Pay with $methodLabel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total amount: ${formatRwf(amountRwf)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'A USSD prompt will be sent to this number. Enter your PIN to confirm payment.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Phone number (078... / 073...)',
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, phone.text.trim()),
            child: const Text('Send USSD'),
          ),
        ],
      );
    },
  );
}
