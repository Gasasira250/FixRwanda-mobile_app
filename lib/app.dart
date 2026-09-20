import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/account_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/professional_detail_screen.dart';
import 'screens/provider_onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/review_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tracking_screen.dart';
import 'state/marketplace_controller.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

class FixRwandaApp extends StatelessWidget {
  const FixRwandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeShell());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/admin':
            return MaterialPageRoute(builder: (_) => const AdminScreen());
          case '/onboarding':
            return MaterialPageRoute(
              builder: (_) => const ProviderOnboardingScreen(),
            );
          case '/professional':
            final id = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => ProfessionalDetailScreen(professionalId: id),
            );
          case '/booking':
            final id = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => BookingDetailScreen(bookingId: id),
            );
          case '/payment':
            final id = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => PaymentScreen(bookingId: id),
            );
          case '/tracking':
            final id = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => TrackingScreen(bookingId: id),
            );
          case '/review':
            final id = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => ReviewScreen(bookingId: id),
            );
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}

class FixRwandaRoot extends StatelessWidget {
  const FixRwandaRoot({super.key, required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: const FixRwandaApp(),
    );
  }
}
