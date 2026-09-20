import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../state/marketplace_controller.dart';
import '../widgets/app_states.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  UserRole role = UserRole.customer;

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final controller = context.read<MarketplaceController>();
    final ok = await controller.register(
      fullName: name.text,
      email: email.text,
      phoneNumber: phone.text,
      password: password.text,
      role: role,
    );
    if (!mounted) return;
    if (ok) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              if (controller.errorMessage != null)
                ErrorBanner(message: controller.errorMessage!),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) =>
                    (value == null || value.trim().length < 3)
                        ? 'Enter your full name'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    (value == null || !value.contains('@'))
                        ? 'Enter a valid email'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+2507...',
                ),
                validator: (value) =>
                    (value == null || value.trim().length < 10)
                        ? 'Enter a valid phone number'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) =>
                    (value == null || value.length < 6)
                        ? 'Use at least 6 characters'
                        : null,
              ),
              const SizedBox(height: 12),
              RadioGroup<UserRole>(
                groupValue: role,
                onChanged: (value) {
                  if (value != null) setState(() => role = value);
                },
                child: const Column(
                  children: [
                    RadioListTile<UserRole>(
                      value: UserRole.customer,
                      title: Text('I need a technician'),
                    ),
                    RadioListTile<UserRole>(
                      value: UserRole.professional,
                      title: Text('I am a professional'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.busy ? null : _submit,
                child: const Text('Create account'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
