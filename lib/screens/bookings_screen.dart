import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/cancellation_policy.dart';
import '../models/booking.dart';
import '../state/marketplace_controller.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final bookings = controller.bookings;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Your bookings',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: bookings.isEmpty
                ? const EmptyState(
                    title: 'No bookings yet',
                    message: 'Choose a category on Home to book a professional.',
                    icon: Icons.calendar_month_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          title: Text(booking.serviceName),
                          subtitle: Text(
                            '${booking.professionalName} · ${Money.rwf(booking.servicePrice)}',
                          ),
                          trailing: StatusPill.booking(booking.status),
                          onTap: () => Navigator.of(context).pushNamed(
                            '/booking',
                            arguments: booking.id,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    Booking? booking;
    for (final item in controller.bookings) {
      if (item.id == bookingId) booking = item;
    }
    if (booking == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Booking not found',
          message: 'This booking is no longer available.',
        ),
      );
    }
    final quote = CancellationPolicy.quote(booking);
    final payment = controller.paymentFor(booking.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (controller.errorMessage != null)
            ErrorBanner(message: controller.errorMessage!),
          Text(booking.serviceName,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          StatusPill.booking(booking.status),
          const SizedBox(height: 12),
          Text(booking.professionalName),
          Text(
            '${booking.scheduledDate.year}-${booking.scheduledDate.month.toString().padLeft(2, '0')}-${booking.scheduledDate.day.toString().padLeft(2, '0')} · ${booking.scheduledTime}',
          ),
          Text(booking.customerAddress),
          Text(Money.rwf(booking.servicePrice)),
          if (payment != null) Text('Payment: ${payment.status.name}'),
          if (booking.refundAmountRwf != null)
            Text('Refund: ${Money.rwf(booking.refundAmountRwf!)}'),
          const SizedBox(height: 20),
          if (booking.status == BookingStatus.pending)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                '/payment',
                arguments: booking!.id,
              ),
              child: const Text('Complete payment'),
            ),
          if (quote.canCancel) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(quote.title),
                    content: Text(quote.message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Keep booking'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Cancel booking'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await controller.cancelBooking(booking!.id);
                }
              },
              child: const Text('Cancel booking'),
            ),
          ] else if (booking.status == BookingStatus.inProgress ||
              booking.status == BookingStatus.completed)
            Text(quote.message),
          if (controller.isAdmin || booking.status != BookingStatus.pending) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => controller.advanceBooking(booking!.id),
              child: const Text('Advance job status'),
            ),
          ],
          if (booking.status == BookingStatus.completed) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                '/review',
                arguments: booking!.id,
              ),
              child: const Text('Leave a review'),
            ),
          ],
        ],
      ),
    );
  }
}
