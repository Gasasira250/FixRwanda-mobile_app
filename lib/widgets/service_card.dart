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
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconFor(category),
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
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
                    fontWeight: FontWeight.w600,
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
