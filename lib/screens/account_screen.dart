import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_config.dart';
import '../state/marketplace_controller.dart';
import '../theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final user = controller.user;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  user?.phoneNumber ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('${AppConfig.market} · ${AppConfig.language}'),
            onTap: () => Navigator.of(context).pushNamed('/settings'),
          ),
          if (controller.isProfessional)
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Provider verification'),
              subtitle: Text(
                controller.myProfessional?.kigaliGreenBadge == true
                    ? 'Kigali Green Badge is active'
                    : 'Complete NIDA, Irembo, and trade documents',
              ),
              onTap: () => Navigator.of(context).pushNamed('/onboarding'),
            ),
          if (controller.isAdmin)
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Verification queue'),
              onTap: () => Navigator.of(context).pushNamed('/admin'),
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
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
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const ListTile(
        title: Text('Market'),
        subtitle: Text('${AppConfig.market} · ${AppConfig.language}'),
      ),
    );
  }
}
