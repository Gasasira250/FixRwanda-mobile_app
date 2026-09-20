import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/job_map.dart';
import '../widgets/status_timeline.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  var _cancelling = false;

  Future<void> _cancelBooking(
    AppController app,
    CancellationQuote quote,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(quote.title),
          content: Text(
            'Cancellation fee: ${formatRwf(quote.cancellationFeeRwf)}\n'
            'Refund: ${formatRwf(quote.refundAmountRwf)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep booking'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      final cancelled = await app.cancelBooking(widget.bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking cancelled successfully. Refund ${formatRwf(cancelled.refundAmountRwf ?? 0)}.',
          ),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = FixRwandaScope.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final booking = app.bookingById(widget.bookingId);
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Booking Details')),
            body: const Center(child: Text('Booking not found.')),
          );
        }

        final cancelled = booking.status == BookingStatus.cancelled;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('Booking Details'),
          ),
          body: FutureBuilder<CancellationQuote>(
            future: app.quoteCancellation(booking),
            builder: (context, snapshot) {
              final quote = snapshot.data;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OverviewCard(booking: booking),
                    const SizedBox(height: 16),
                    JobMapCard(query: booking.location),
                    if (booking.isUpcoming) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/tracking',
                              arguments: booking,
                            );
                          },
                          icon: const Icon(Icons.near_me_outlined),
                          label: const Text('Track on map'),
                        ),
                      ),
                    ],
                    if (!cancelled) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Booking status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StatusTimeline(status: booking.status),
                    ],
                    const SizedBox(height: 24),
                    _InfoCard(
                      child: Column(
                        children: [
                          _RowLine(
                            label: 'Paid with',
                            value: booking.paymentMethod.label,
                          ),
                          const SizedBox(height: 10),
                          _RowLine(
                            label: 'Reference',
                            value: booking.paymentReference ?? '—',
                          ),
                          if (booking.paymentStatus != null) ...[
                            const SizedBox(height: 10),
                            _RowLine(
                              label: 'Payment',
                              value: booking.paymentStatus!,
                            ),
                          ],
                          if (cancelled) ...[
                            const SizedBox(height: 10),
                            _RowLine(
                              label: 'Refund',
                              value: formatRwf(booking.refundAmountRwf ?? 0),
                            ),
                            const SizedBox(height: 10),
                            _RowLine(
                              label: 'Cancel fee',
                              value: formatRwf(booking.cancellationFeeRwf ?? 0),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (quote != null && quote.canCancel) ...[
                      const SizedBox(height: 24),
                      _InfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cancel booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              quote.message,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              quote.cancellationFeeRwf == 0
                                  ? 'Refund: ${formatRwf(quote.refundAmountRwf)}'
                                  : 'Fee: ${formatRwf(quote.cancellationFeeRwf)}  •  Refund: ${formatRwf(quote.refundAmountRwf)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _cancelling
                                    ? null
                                    : () => _cancelBooking(app, quote),
                                child: _cancelling
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Cancel booking',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (booking.status == BookingStatus.completed) ...[
                      const SizedBox(height: 24),
                      _InfoCard(
                        child: Text(
                          'Completed bookings cannot be cancelled.',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.forBooking(booking.status);
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.professionalName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tone.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.statusLabel,
                  style: TextStyle(
                    color: tone.foreground,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.service,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const Divider(height: 30),
          _RowLine(
            label: 'Appointment date',
            value: formatDateTime(booking.scheduledAt),
          ),
          const SizedBox(height: 10),
          _RowLine(
            label: 'Location',
            value: booking.location,
          ),
          const SizedBox(height: 10),
          _RowLine(
            label: 'Total amount',
            value: formatRwf(booking.serviceFeeRwf),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _RowLine extends StatelessWidget {
  const _RowLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: emphasize ? AppColors.primaryBlue : AppColors.ink,
              fontSize: emphasize ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
