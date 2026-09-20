import 'package:flutter/material.dart';

import '../models/payment.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({
    super.key,
    required this.payment,
    required this.bookingId,
  });

  final Payment payment;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final success = payment.status == PaymentStatus.success;
    return Scaffold(
      appBar: AppBar(title: Text(success ? 'Escrow held' : 'Escrow failed')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              size: 72,
              color: success ? AppTheme.accentGreen : Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              success
                  ? 'Payment is held in escrow. The closest verified technician in Gasabo, Kicukiro, or Nyarugenge has 15 minutes to accept. If they do not, the next 3 closest verified providers are offered. They are paid only after entering the 4-digit code shown on your screen.'
                  : 'Escrow pre-authorisation failed. The job is still pending, so you can try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('${Money.rwf(payment.amount)} · ${payment.status.name}'),
            if (payment.transactionReference != null)
              Text('Ref ${payment.transactionReference}'),
            const Spacer(),
            if (!success)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(
                  '/payment',
                  arguments: bookingId,
                ),
                child: const Text('Try again'),
              ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              ),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}
