import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFD6F5E3),
                child: Icon(Icons.check, color: AppColors.green, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking confirmed',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '${booking.id}  •  ${booking.paymentMethod.label}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              Text(
                '${booking.professionalName}\n${booking.service}\n${formatDateTime(booking.scheduledAt)}\n${formatRwf(booking.serviceFeeRwf)}',
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.5, fontSize: 16),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/booking-detail',
                    arguments: booking.id,
                  );
                },
                child: const Text('Track booking'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil(
                    (route) => route.settings.name == '/home',
                  );
                },
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
