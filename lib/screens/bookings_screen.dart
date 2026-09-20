import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = FixRwandaScope.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final upcoming = app.bookings.where((item) => item.isUpcoming).toList();
        final past = app.bookings.where((item) => item.isPast).toList();
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: app.refreshBookings,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                const Text(
                  'My bookings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                if (app.bookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Text(
                      'No bookings yet. Book a verified professional from Home.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                else ...[
                  if (upcoming.isNotEmpty) ...[
                    const Text(
                      'Active',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    for (final booking in upcoming) _BookingTile(booking: booking),
                    const SizedBox(height: 18),
                  ],
                  if (past.isNotEmpty) ...[
                    const Text(
                      'History',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    for (final booking in past) _BookingTile(booking: booking),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(booking.professionalName),
        subtitle: Text(
          '${booking.service} • ${formatDateTime(booking.scheduledAt)}\n${booking.statusLabel}',
        ),
        isThreeLine: true,
        trailing: Text(
          formatRwf(booking.serviceFeeRwf),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/booking-detail',
            arguments: booking.id,
          );
        },
      ),
    );
  }
}
