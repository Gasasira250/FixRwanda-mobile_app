import 'dart:async';

import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_surfaces.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  Future<void> _open() async {
    final app = FixRwandaScope.of(context);
    await app.restoreSession();
    if (!mounted) return;
    await app.api.discover();
    if (!mounted) return;
    _timer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        app.isSignedIn ? '/home' : '/login',
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.skyDark, AppColors.primaryBlue],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandMark(size: 84),
                const SizedBox(height: 22),
                const Text(
                  'FixRwanda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 56,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.sunYellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Verified professionals, booked in minutes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFD6E6F7), fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
