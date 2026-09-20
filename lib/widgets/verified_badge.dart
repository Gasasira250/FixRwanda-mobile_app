import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../theme/app_theme.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    required this.professional,
    this.compact = false,
  });

  final Professional professional;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final verified = professional.isVerifiedProfessional;
    final color = verified ? AppColors.green : AppColors.warning;
    final label = compact
        ? (verified ? 'Verified' : 'Pending')
        : professional.verificationLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified : Icons.hourglass_bottom,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
