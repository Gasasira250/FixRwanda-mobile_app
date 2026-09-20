import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/launchers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = FixRwandaScope.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final customer = app.customer;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.person, color: AppColors.tab),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer?.name ?? 'Guest',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              customer?.identifier ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _AccountMenuTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        onTap: () => Navigator.of(context)
                            .pushNamed('/account/profile'),
                      ),
                      const Divider(height: 1),
                      _AccountMenuTile(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        subtitle: 'MTN Mobile Money, Airtel, Card',
                        onTap: () => Navigator.of(context)
                            .pushNamed('/account/payments'),
                      ),
                      const Divider(height: 1),
                      _AccountMenuTile(
                        icon: Icons.history,
                        title: 'Booking History',
                        onTap: () => Navigator.of(context)
                            .pushNamed('/account/history'),
                      ),
                      const Divider(height: 1),
                      _AccountMenuTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () => Navigator.of(context)
                            .pushNamed('/account/support'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      app.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (_) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign out',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _identifier;
  var _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final customer = FixRwandaScope.of(context).customer;
    _name = TextEditingController(text: customer?.name ?? '');
    _identifier = TextEditingController(text: customer?.identifier ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _identifier.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    FixRwandaScope.of(context).updateProfile(
      name: _name.text,
      identifier: _identifier.text,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            const Text(
              'Personal details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'These details appear on your bookings and receipts.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _identifier,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Phone or email',
                prefixIcon: Icon(Icons.contact_mail_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a phone number or email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save details')),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = FixRwandaScope.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Payment methods')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              const Text(
                'How you pay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose MTN Mobile Money, Airtel Money, or card for your bookings.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              _ElevatedAccountCard(
                child: RadioGroup<PaymentMethod>(
                  groupValue: app.preferredPaymentMethod,
                  onChanged: (value) {
                    if (value != null) {
                      app.setPreferredPaymentMethod(value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final method in PaymentMethod.values) ...[
                        if (method != PaymentMethod.values.first)
                          const Divider(height: 1),
                        RadioListTile<PaymentMethod>(
                          value: method,
                          secondary: Icon(
                            _paymentIcon(method),
                            color: AppColors.skyDark,
                          ),
                          title: Text(method.label),
                          subtitle: Text(method.hint),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _paymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mtnMomo:
        return Icons.phone_android;
      case PaymentMethod.airtelMoney:
        return Icons.smartphone;
      case PaymentMethod.card:
        return Icons.credit_card;
    }
  }
}

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final _location = TextEditingController();

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = FixRwandaScope.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final history = [...app.bookings]
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
        return Scaffold(
          appBar: AppBar(title: const Text('History & locations')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              const Text(
                'Booking history',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (history.isEmpty)
                const Text(
                  'No bookings yet. Jobs you book will appear here.',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                _ElevatedAccountCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < history.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.handyman_outlined),
                          title: Text(history[i].service),
                          subtitle: Text(
                            '${history[i].professionalName} · ${history[i].statusLabel}',
                          ),
                          trailing: Text(formatRwf(history[i].serviceFeeRwf)),
                          onTap: () => Navigator.of(context).pushNamed(
                            '/booking-detail',
                            arguments: history[i].id,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Saved locations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _ElevatedAccountCard(
                child: Column(
                  children: [
                    if (app.savedLocations.isEmpty)
                      const ListTile(
                        title: Text('No saved locations yet'),
                      )
                    else
                      for (var i = 0; i < app.savedLocations.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(app.savedLocations[i]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                app.removeSavedLocation(app.savedLocations[i]),
                          ),
                        ),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: 'Add a location',
                  hintText: 'Kigali, Kicukiro',
                  prefixIcon: Icon(Icons.add_location_alt_outlined),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  app.addSavedLocation(_location.text);
                  _location.clear();
                },
                child: const Text('Save location'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SupportLegalScreen extends StatelessWidget {
  const SupportLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support & legal')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            'Support',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Need help with a booking or verification? Email  '
            'support@fixrwanda.rw or call 0780 000 000. We reply during '
            'business hours, Monday to Saturday.',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          SizedBox(height: 16),
          _SupportActions(),
          SizedBox(height: 24),
          Text(
            'Privacy policy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'FixRwanda stores your name, contact details, booking locations, '
            'and payment method choice to complete jobs. We do not sell your '
            'data. Card and Mobile Money details are processed securely and '
            'are never stored as PINs.',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          SizedBox(height: 24),
          Text(
            'Terms of service',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Bookings are confirmed after payment. Cancellation and '
            'refunds follow the in-app policy (full refund before a pro is '
            'en route, a transport fee after that, and 50% once work has '
            'started). Completed jobs cannot be cancelled.',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _SupportActions extends StatelessWidget {
  const _SupportActions();

  static const _supportPhone = '0780000000';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await makePhoneCall(_supportPhone);
              if (!context.mounted) return;
              await showLaunchResult(
                context,
                ok: ok,
                fallback: 'Call $_supportPhone from a phone.',
              );
            },
            icon: const Icon(Icons.call),
            label: const Text('Call'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await sendSms(
                _supportPhone,
                body: 'Hello FixRwanda support, I need help with a booking.',
              );
              if (!context.mounted) return;
              await showLaunchResult(
                context,
                ok: ok,
                fallback: 'SMS $_supportPhone from a phone.',
              );
            },
            icon: const Icon(Icons.sms_outlined),
            label: const Text('SMS'),
          ),
        ),
      ],
    );
  }
}

class _ElevatedAccountCard extends StatelessWidget {
  const _ElevatedAccountCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.ink.withValues(alpha: 0.14),
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  const _AccountMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.skyDark),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
