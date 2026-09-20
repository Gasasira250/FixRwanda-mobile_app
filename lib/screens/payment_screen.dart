import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/momo_payment_dialog.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.mtnMomo;
  bool _paying = false;
  String? _error;
  String? _ussdHint;

  bool get _isMoMo =>
      _method == PaymentMethod.mtnMomo || _method == PaymentMethod.airtelMoney;

  Future<void> _pay() async {
    setState(() {
      _paying = true;
      _error = null;
      _ussdHint = null;
    });
    try {
      final app = FixRwandaScope.of(context);
      if (_isMoMo) {
        final phone = await showMoMoPaymentDialog(
          context,
          amountRwf: widget.draft.serviceFeeRwf,
          methodLabel: _method.label,
        );
        if (!mounted) return;
        if (phone == null || phone.isEmpty) {
          setState(() => _paying = false);
          return;
        }
        final push = await app.requestMoMo(
          phoneNumber: phone,
          amountRwf: widget.draft.serviceFeeRwf,
          method: _method,
        );
        if (!mounted) return;
        setState(() => _ussdHint = push['message'] as String?);
        await Future<void>.delayed(const Duration(milliseconds: 900));
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 700));
      }
      if (!mounted) return;
      final booking = await app.payAndConfirm(
        draft: widget.draft,
        method: _method,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/booking-success',
        (route) => route.settings.name == '/home',
        arguments: booking,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = error.toString().replaceFirst('AuthException: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Text(
            'Choose a payment method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'MTN MoMo and Airtel Money send a USSD prompt to your phone. Card is charged securely.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          RadioGroup<PaymentMethod>(
            groupValue: _method,
            onChanged: (value) {
              if (value != null) setState(() => _method = value);
            },
            child: Column(
              children: [
                for (final method in PaymentMethod.values)
                  RadioListTile<PaymentMethod>(
                    value: method,
                    title: Text(method.label),
                    subtitle: Text(method.hint),
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Amount',
            style: TextStyle(fontSize: 16, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            formatRwf(widget.draft.serviceFeeRwf),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          if (_ussdHint != null) ...[
            const SizedBox(height: 12),
            Text(_ussdHint!, style: const TextStyle(color: AppColors.green)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _paying ? null : _pay,
            child: _paying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isMoMo
                        ? 'Pay with ${_method.label} USSD'
                        : 'Pay with ${_method.label}',
                  ),
          ),
        ],
      ),
    );
  }
}
