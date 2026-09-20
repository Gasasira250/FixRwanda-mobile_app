import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryLook {
  static IconData icon(String category) {
    return switch (category) {
      'Electrical Installation' => Icons.electrical_services_rounded,
      'Plumbing' => Icons.plumbing_rounded,
      'House Cleaning' => Icons.cleaning_services_rounded,
      'Appliance Repair' => Icons.kitchen_rounded,
      'Computer & IT Support' => Icons.computer_rounded,
      'Car Repair' => Icons.car_repair_rounded,
      'Painting' => Icons.format_paint_rounded,
      'Construction' => Icons.construction_rounded,
      'Hair Styling' => Icons.content_cut_rounded,
      'Beauty Services' => Icons.spa_rounded,
      _ => Icons.handyman_rounded,
    };
  }

  static Color tint(String category) {
    return switch (category) {
      'Electrical Installation' => AppTheme.primaryColor,
      'Plumbing' => const Color(0xFF0E7490),
      'House Cleaning' => AppTheme.accentGreen,
      'Appliance Repair' => const Color(0xFFB45309),
      'Computer & IT Support' => const Color(0xFF4338CA),
      'Car Repair' => const Color(0xFF9F1239),
      'Painting' => const Color(0xFFCA8A04),
      'Construction' => const Color(0xFF334155),
      'Hair Styling' => const Color(0xFFBE185D),
      'Beauty Services' => const Color(0xFF7C3AED),
      _ => AppTheme.primaryColor,
    };
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.accent,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: const Color(0xFFEEF2F7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: accent == null
          ? Padding(padding: padding, child: child)
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: accent),
                  Expanded(child: Padding(padding: padding, child: child)),
                ],
              ),
            ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class TrustChip extends StatelessWidget {
  const TrustChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class IconWell extends StatelessWidget {
  const IconWell({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}
