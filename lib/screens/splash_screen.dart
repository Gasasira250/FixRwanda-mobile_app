import 'dart:async';

import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

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
    return const Scaffold(
      backgroundColor: AppColors.skyDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.gold,
                child: Icon(Icons.handyman, size: 42, color: AppColors.skyDark),
              ),
              SizedBox(height: 22),
              Text(
                'FixRwanda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Verified professionals, booked in minutes.',
                style: TextStyle(color: Color(0xFFB8D4E8), fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
