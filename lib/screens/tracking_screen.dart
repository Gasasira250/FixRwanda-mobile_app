import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../models/payment.dart';
import '../state/marketplace_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_states.dart';
import '../widgets/verification_badges.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    Booking? booking;
    for (final item in [
      ...controller.bookings,
      ...controller.openJobs,
      ...controller.assignedJobs,
    ]) {
      if (item.id == bookingId) booking = item;
    }
    if (booking == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Tracking unavailable',
          message: 'This job is not being tracked yet.',
        ),
      );
    }
    final isClient = !controller.isProfessional;
    final matches = controller.professionals.where(
      (item) => item.id == booking!.professionalId,
    );
    final badgeHolder = matches.isEmpty ? null : matches.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Live job tracker')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusPill.booking(booking.status),
            const SizedBox(height: 8),
            Text(
              booking.professionalName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(booking.customerAddress),
            Text('Escrow ${booking.paymentState.apiName}'),
            if (badgeHolder != null) ...[
              const SizedBox(height: 8),
              VerificationBadges(professional: badgeHolder),
            ],
            if (isClient &&
                booking.completionOtp != null &&
                booking.status == BookingStatus.inProgress) ...[
              const SizedBox(height: 12),
              const Text('Show this code only after the work is finished:'),
              Text(
                booking.completionOtp!,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(
                  painter: _RoutePainter(
                    progress: booking.status == BookingStatus.enRoute
                        ? 0.45
                        : booking.status == BookingStatus.arrived ||
                                booking.status == BookingStatus.inProgress
                            ? 1
                            : 0.12,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.navigation_rounded,
                          color: AppTheme.secondaryColor,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.status == BookingStatus.enRoute
                              ? 'Live GPS while technician is EN_ROUTE'
                              : 'Technician location',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (booking.providerLatitude != null)
                          Text(
                            '${booking.providerLatitude!.toStringAsFixed(5)}, ${booking.providerLongitude!.toStringAsFixed(5)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        if (booking.lastLocationAt != null)
                          Text(
                            'Updated ${booking.lastLocationAt!.hour.toString().padLeft(2, '0')}:${booking.lastLocationAt!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white54),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0052B4)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.25,
      );
    canvas.drawPath(path, paint);
    final metric = path.computeMetrics().first;
    final tangent =
        metric.getTangentForOffset(metric.length * progress.clamp(0, 1));
    if (tangent != null) {
      canvas.drawCircle(
        tangent.position,
        10,
        Paint()..color = const Color(0xFFFAD201),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
