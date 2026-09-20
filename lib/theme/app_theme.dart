import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/booking.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF0052B4);
  static const Color sunYellow = Color(0xFFFAD201);
  static const Color kigaliGreen = Color(0xFF208A42);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  static const Color sky = primaryBlue;
  static const Color skyDark = Color(0xFF003A82);
  static const Color green = kigaliGreen;
  static const Color gold = sunYellow;
  static const Color cream = backgroundLight;
  static const Color canvas = Color(0xFF0F172A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color tab = primaryBlue;
  static const Color ink = darkSlate;
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFB42318);
  static const Color warning = Color(0xFFB54708);

  static const Color primarySoft = Color(0xFFE8F1FB);
  static const Color yellowSoft = Color(0xFFFFF6CC);
  static const Color greenSoft = Color(0xFFD9F0E3);
  static const Color dangerSoft = Color(0xFFFDE8E6);
}

class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.darkSlate.withValues(alpha: 0.07),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

class StatusTone {
  const StatusTone({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  static StatusTone forBooking(BookingStatus status) {
    switch (status) {
      case BookingStatus.cancelled:
        return const StatusTone(
          background: AppColors.dangerSoft,
          foreground: AppColors.danger,
        );
      case BookingStatus.completed:
        return const StatusTone(
          background: AppColors.greenSoft,
          foreground: AppColors.kigaliGreen,
        );
      case BookingStatus.inProgress:
      case BookingStatus.enRoute:
      case BookingStatus.arrived:
        return const StatusTone(
          background: AppColors.yellowSoft,
          foreground: Color(0xFF8A6D00),
        );
      case BookingStatus.confirmed:
        return const StatusTone(
          background: AppColors.primarySoft,
          foreground: AppColors.primaryBlue,
        );
    }
  }
}

class AppTheme {
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color sunYellow = AppColors.sunYellow;
  static const Color kigaliGreen = AppColors.kigaliGreen;
  static const Color darkSlate = AppColors.darkSlate;
  static const Color backgroundLight = AppColors.backgroundLight;

  static ThemeData get lightTheme => light();

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.skyDark,
      secondary: AppColors.sunYellow,
      onSecondary: AppColors.darkSlate,
      tertiary: AppColors.kigaliGreen,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.darkSlate,
      error: AppColors.danger,
      onError: Colors.white,
      outline: AppColors.line,
    );

    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.primaryBlue,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySoft,
        selectedColor: AppColors.primaryBlue,
        labelStyle: const TextStyle(
          color: AppColors.skyDark,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIconColor: AppColors.primaryBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryBlue : AppColors.muted,
          );
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      dividerColor: AppColors.line,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
      ),
    );
  }
}
