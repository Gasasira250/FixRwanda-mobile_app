import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_config.dart';
import '../models/user.dart';
import '../state/marketplace_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/market_design.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final user = controller.user;
    final roleLabel = switch (user?.role) {
      UserRole.professional => 'Provider',
      UserRole.admin => 'Admin',
      _ => 'Customer',
    };

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.heroNavy],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.secondaryColor,
                    child: Text(
                      (user?.fullName.isNotEmpty == true)
                          ? user!.fullName[0].toUpperCase()
                          : 'F',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$roleLabel · ${user?.phoneNumber ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          child: Column(
            children: [
              _AccountTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: '${AppConfig.market} · ${AppConfig.language}',
                onTap: () => Navigator.of(context).pushNamed('/settings'),
              ),
              if (controller.isProfessional)
                _AccountTile(
                  icon: Icons.verified_outlined,
                  title: 'Provider verification',
                  subtitle: controller.myProfessional?.kigaliGreenBadge == true
                      ? 'Kigali Green Badge is active'
                      : 'Complete NIDA, Irembo, and trade documents',
                  onTap: () => Navigator.of(context).pushNamed('/onboarding'),
                ),
              if (controller.isAdmin)
                _AccountTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Verification queue',
                  subtitle: 'Review documents and disputes',
                  onTap: () => Navigator.of(context).pushNamed('/admin'),
                ),
              _AccountTile(
                icon: Icons.logout,
                title: 'Sign out',
                subtitle: 'Return to the FixRwanda sign-in screen',
                onTap: () async {
                  await controller.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        onTap: onTap,
        child: Row(
          children: [
            IconWell(icon: icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.mutedTextColor),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SurfaceCard(
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Market'),
            subtitle: Text('${AppConfig.market} · ${AppConfig.language}'),
          ),
        ),
      ),
    );
  }
}
