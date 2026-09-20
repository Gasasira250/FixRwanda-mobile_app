import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payment.dart';
import '../state/marketplace_controller.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';
import 'payment_result_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod method = PaymentMethod.mtnMomo;
  final phone = TextEditingController(text: '+250788123456');

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final controller = context.read<MarketplaceController>();
    final payment = await controller.payBooking(
      bookingId: widget.bookingId,
      method: method,
      phoneNumber: phone.text,
    );
    if (!mounted || payment == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen(
          payment: payment,
          bookingId: widget.bookingId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final booking = [
      for (final item in controller.bookings)
        if (item.id == widget.bookingId) item,
    ].firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.errorMessage != null)
              ErrorBanner(message: controller.errorMessage!),
            Text(
              booking == null
                  ? 'Confirm payment'
                  : 'Hold ${Money.rwf(booking.servicePrice)} in escrow',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'MoMo is pre-authorised into FixRwanda escrow. The technician is paid 85% only after you confirm with a 4-digit OTP. Cash to the provider is not allowed. Numbers ending in 0000 are declined.',
            ),
            const SizedBox(height: 16),
            RadioGroup<PaymentMethod>(
              groupValue: method,
              onChanged: (next) {
                if (next != null) setState(() => method = next);
              },
              child: Column(
                children: [
                  for (final value in PaymentMethod.values)
                    RadioListTile<PaymentMethod>(
                      value: value,
                      title: Text(switch (value) {
                        PaymentMethod.mtnMomo => 'MTN MoMo',
                        PaymentMethod.airtelMoney => 'Airtel Money',
                        PaymentMethod.card => 'Card',
                      }),
                    ),
                ],
              ),
            ),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'MoMo / card phone number',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: controller.busy ? null : _pay,
              child: controller.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Pay now'),
            ),
          ],
        ),
      ),
    );
  }
}
