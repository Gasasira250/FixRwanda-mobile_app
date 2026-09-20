import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/professional.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  factory StatusPill.booking(BookingStatus status) {
    final color = switch (status) {
      BookingStatus.pending => Colors.orange,
      BookingStatus.confirmed => AppTheme.primaryColor,
      BookingStatus.enRoute => Colors.deepPurple,
      BookingStatus.arrived => Colors.teal,
      BookingStatus.inProgress => AppTheme.accentGreen,
      BookingStatus.completed => AppTheme.accentGreen,
      BookingStatus.cancelled => Colors.redAccent,
    };
    final label = switch (status) {
      BookingStatus.pending => 'Pending',
      BookingStatus.confirmed => 'Confirmed',
      BookingStatus.enRoute => 'En route',
      BookingStatus.arrived => 'Arrived',
      BookingStatus.inProgress => 'In progress',
      BookingStatus.completed => 'Completed',
      BookingStatus.cancelled => 'Cancelled',
    };
    return StatusPill(label: label, color: color);
  }

  factory StatusPill.verification(VerificationStatus status) {
    final color = switch (status) {
      VerificationStatus.verified => AppTheme.accentGreen,
      VerificationStatus.pending => Colors.orange,
      VerificationStatus.rejected => Colors.redAccent,
      VerificationStatus.expired => Colors.blueGrey,
    };
    return StatusPill(
      label: status.name[0].toUpperCase() + status.name.substring(1),
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.mutedTextColor),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFFB42318))),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Loading...'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
