import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({
    super.key,
    required this.professional,
    required this.onViewProfile,
    this.wide = false,
  });

  final Professional professional;
  final VoidCallback onViewProfile;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final verified = professional.isVerifiedProfessional;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          professional.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${professional.trade} • ${professional.location}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.sunYellow, size: 16),
            const SizedBox(width: 4),
            Text(
              professional.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '(${professional.jobsCompleted} jobs)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              verified ? Icons.verified : Icons.hourglass_bottom,
              color: verified ? AppColors.kigaliGreen : AppColors.warning,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              verified ? 'Verified' : 'Pending',
              style: TextStyle(
                color: verified ? AppColors.kigaliGreen : AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (!wide) const Spacer() else const SizedBox(height: 12),
        Text(
          formatRwf(professional.serviceFeeRwf),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            onPressed: onViewProfile,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(36),
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'View profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewProfile,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: wide ? double.infinity : 206,
          height: wide ? null : 232,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.card,
          ),
          child: content,
        ),
      ),
    );
  }
}
