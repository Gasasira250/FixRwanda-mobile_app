import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../theme/app_theme.dart';
import 'app_states.dart';

class VerificationBadges extends StatelessWidget {
  const VerificationBadges({super.key, required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Badge(
          label: 'Phone',
          status: professional.phoneVerificationStatus,
        ),
        _Badge(
          label: 'National ID',
          status: professional.idVerificationStatus,
        ),
        _Badge(
          label: 'Liveness',
          status: professional.livenessVerificationStatus,
        ),
        _Badge(
          label: 'Irembo',
          status: professional.iremboVerificationStatus,
        ),
        _Badge(
          label: 'TVET / RDB',
          status: professional.tvetVerificationStatus,
        ),
        _Badge(
          label: 'Overall',
          status: professional.verificationStatus,
        ),
        if (professional.kigaliGreenBadge) const KigaliGreenBadge(),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.status});

  final String label;
  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == VerificationStatus.verified
                ? Icons.verified_rounded
                : Icons.hourglass_bottom_rounded,
            size: 16,
            color: status == VerificationStatus.verified
                ? AppTheme.accentGreen
                : AppTheme.mutedTextColor,
          ),
          const SizedBox(width: 6),
          Text('$label: '),
          StatusPill.verification(status),
        ],
      ),
    );
  }
}

class KigaliGreenBadge extends StatelessWidget {
  const KigaliGreenBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 16, color: AppTheme.accentGreen),
          SizedBox(width: 6),
          Text(
            'Kigali Green Badge',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
