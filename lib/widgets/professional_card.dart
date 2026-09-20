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
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${professional.trade} • ${professional.location}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              professional.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '(${professional.jobsCompleted} jobs)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              verified ? Icons.verified : Icons.hourglass_bottom,
              color: verified ? AppColors.green : AppColors.warning,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              verified ? 'Verified' : 'Pending',
              style: TextStyle(
                color: verified ? AppColors.green : AppColors.warning,
                fontSize: 11,
              ),
            ),
          ],
        ),
        if (!wide) const Spacer() else const SizedBox(height: 12),
        Text(
          formatRwf(professional.serviceFeeRwf),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 34,
          child: ElevatedButton(
            onPressed: onViewProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tab,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(34),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onViewProfile,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: wide ? double.infinity : 200,
          height: wide ? null : 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}
