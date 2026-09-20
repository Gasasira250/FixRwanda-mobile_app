import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_surfaces.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.card,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.kigaliGreen,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking confirmed',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.sunYellow,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${booking.id}  •  ${booking.paymentMethod.label}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              SurfaceCard(
                child: Text(
                  '${booking.professionalName}\n${booking.service}\n${formatDateTime(booking.scheduledAt)}\n${formatRwf(booking.serviceFeeRwf)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.6, fontSize: 16),
                ),
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
