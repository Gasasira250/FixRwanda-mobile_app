import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/broadcast_router.dart';
import '../models/service.dart';
import '../repositories/booking_repository.dart';
import '../state/marketplace_controller.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';
import 'payment_screen.dart';

class JobRequestScreen extends StatefulWidget {
  const JobRequestScreen({super.key, required this.category, this.basePrice = 20000});

  final String category;
  final int basePrice;

  @override
  State<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends State<JobRequestScreen> {
  late List<Service> services;
  Service? selected;
  String district = kigaliDistricts.first;
  final address = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    services = context.read<MarketplaceController>().servicesForCategory(widget.category);
    selected = services.isEmpty ? null : services.first;
  }

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate() || selected == null) return;
    final controller = context.read<MarketplaceController>();
    final booking = await controller.createBooking(
      CreateBookingInput(
        serviceId: selected!.id,
        serviceName: selected!.name,
        category: widget.category,
        scheduledDate: DateTime.now(),
        scheduledTime: 'Now',
        customerAddress: address.text.trim(),
        servicePrice: selected!.priceRwf,
        district: district,
        sector: district,
      ),
    );
    if (!mounted || booking == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PaymentScreen(bookingId: booking.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Request a technician')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (controller.errorMessage != null)
              ErrorBanner(message: controller.errorMessage!),
            Text(widget.category, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Payment is held in FixRwanda escrow. The closest verified technician in Gasabo, Kicukiro, or Nyarugenge is offered first. If they do not accept in 15 minutes, the next 3 closest verified providers are offered. Cash to the technician is not allowed.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Service>(
              initialValue: selected,
              items: [
                for (final service in services)
                  DropdownMenuItem(
                    value: service,
                    child: Text('${service.name} · ${Money.rwf(service.priceRwf)}'),
                  ),
              ],
              onChanged: (value) => setState(() => selected = value),
              decoration: const InputDecoration(labelText: 'Service'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: district,
              items: [
                for (final item in kigaliDistricts)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) => setState(() => district = value ?? district),
              decoration: const InputDecoration(labelText: 'District'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: address,
              decoration: const InputDecoration(
                labelText: 'Street address',
                hintText: 'KN 5 Ave, house number',
              ),
              validator: (value) =>
                  (value == null || value.trim().length < 5)
                      ? 'Enter the service address'
                      : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.busy ? null : _submit,
              child: Text(
                'Hold payment in escrow${selected == null ? '' : ' · ${Money.rwf(selected!.priceRwf)}'}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
