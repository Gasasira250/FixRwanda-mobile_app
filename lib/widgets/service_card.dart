import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final ServiceCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconFor(category), color: AppColors.tab, size: 28),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData iconFor(ServiceCategory category) {
    switch (category.id) {
      case 'electrician':
        return Icons.bolt;
      case 'plumber':
        return Icons.plumbing;
      case 'cleaner':
        return Icons.cleaning_services;
      case 'painter':
        return Icons.format_paint;
      case 'carpenter':
        return Icons.handyman;
      case 'hvac':
        return Icons.ac_unit;
      case 'phone':
        return Icons.phone_iphone;
      case 'stylist':
        return Icons.content_cut;
      case 'mason':
        return Icons.foundation;
      case 'tiler':
        return Icons.grid_view;
      case 'mechanic':
        return Icons.car_repair;
      case 'gardener':
        return Icons.grass;
      case 'locksmith':
        return Icons.lock_outline;
      case 'welder':
        return Icons.build;
      default:
        return Icons.handyman_outlined;
    }
  }
}
