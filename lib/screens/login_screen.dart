import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/marketplace_controller.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/app_states.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifier = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final controller = context.read<MarketplaceController>();
    final ok = await controller.login(identifier.text, password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.handyman_rounded, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign in to ${AppConstants.appName}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Book verified professionals across Kigali.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (controller.errorMessage != null)
                  ErrorBanner(message: controller.errorMessage!),
                TextFormField(
                  controller: identifier,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email or phone',
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Enter your email or phone number'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) =>
                      (value == null || value.length < 6)
                          ? 'Enter your password'
                          : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.busy ? null : _submit,
                  child: controller.busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/register'),
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
