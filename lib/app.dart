import 'package:flutter/material.dart';

import 'models/booking.dart';
import 'models/professional.dart';
import 'screens/account_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/booking_success_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/professional_detail_screen.dart';
import 'screens/professionals_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tracking_screen.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/phone_frame.dart';

class FixRwandaApp extends StatelessWidget {
  const FixRwandaApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return FixRwandaScope(
      controller: controller,
      child: MaterialApp(
        title: 'FixRwanda',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        builder: (context, child) {
          final content = child ?? const SizedBox.shrink();
          if (!PhoneFrame.isEnabled) return content;
          return ColoredBox(
            color: AppColors.canvas,
            child: PhoneFrame(child: content),
          );
        },
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final page = switch (settings.name) {
            '/' => const SplashScreen(),
            '/login' => const LoginScreen(),
            '/register' => const RegisterScreen(),
            '/home' => const MainShell(),
            '/professionals' => ProfessionalsScreen(
              args: settings.arguments is ProfessionalsArgs
                  ? settings.arguments as ProfessionalsArgs
                  : const ProfessionalsArgs(),
            ),
            '/professional' => ProfessionalDetailScreen(
              professional: settings.arguments as Professional,
            ),
            '/booking' => BookingScreen(
              professional: settings.arguments as Professional,
            ),
            '/payment' => PaymentScreen(
              draft: settings.arguments as BookingDraft,
            ),
            '/booking-success' => BookingSuccessScreen(
              booking: settings.arguments as Booking,
            ),
            '/booking-detail' => BookingDetailScreen(
              bookingId: settings.arguments as String,
            ),
            '/tracking' => InAppTrackingScreen.fromBooking(
              settings.arguments as Booking,
            ),
            '/account/profile' => const EditProfileScreen(),
            '/account/payments' => const PaymentMethodsScreen(),
            '/account/history' => const BookingHistoryScreen(),
            '/account/support' => const SupportLegalScreen(),
            _ => const SplashScreen(),
          };
          return MaterialPageRoute<void>(
            builder: (_) => page,
            settings: settings,
          );
        },
      ),
    );
  }
}
