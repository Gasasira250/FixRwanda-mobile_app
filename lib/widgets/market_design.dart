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

class AtmosphereBackdrop extends StatelessWidget {
  const AtmosphereBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEEF4FB),
            AppTheme.backgroundColor,
            Color(0xFFF3F7FC),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 180,
            left: -60,
            child: _Blob(
              size: 180,
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -40,
            child: _Blob(
              size: 140,
              color: AppTheme.secondaryColor.withValues(alpha: 0.12),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
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
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
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
        border: Border.all(color: const Color(0xFFE8EEF5)),
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

class DistrictPill extends StatelessWidget {
  const DistrictPill({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor
                  : const Color(0xFFD9E3F0),
            ),
            boxShadow: selected ? null : AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: selected ? AppTheme.secondaryColor : AppTheme.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : AppTheme.textColor,
                ),
              ),
            ],
          ),
        ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class SoftCategoryTile extends StatelessWidget {
  const SoftCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = CategoryLook.tint(category);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                tint.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(color: tint.withValues(alpha: 0.18)),
            boxShadow: AppTheme.cardShadow,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconWell(
                icon: CategoryLook.icon(category),
                color: tint,
                size: 44,
              ),
              const Spacer(),
              Text(
                category,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Book now',
                style: TextStyle(
                  color: tint,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JourneyStrip extends StatelessWidget {
  const JourneyStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (Icons.search_rounded, 'Find'),
      (Icons.lock_rounded, 'Escrow'),
      (Icons.near_me_rounded, 'Track'),
      (Icons.verified_rounded, 'OTP'),
    ];
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      steps[i].$1,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ActiveJobBanner extends StatelessWidget {
  const ActiveJobBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.handyman_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active job',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutedTextColor,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
    );
  }
}
