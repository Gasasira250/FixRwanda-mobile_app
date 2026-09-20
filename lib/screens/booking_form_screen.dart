import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/broadcast_router.dart';
import '../models/professional.dart';
import '../models/service.dart';
import '../repositories/booking_repository.dart';
import '../state/marketplace_controller.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';
import 'payment_screen.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key, required this.professional});

  final Professional professional;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  late List<Service> services;
  Service? selected;
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String time = '09:00';
  late String district;
  final address = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    district = kigaliDistricts.contains(widget.professional.district)
        ? widget.professional.district
        : kigaliDistricts.first;
    services = context
        .read<MarketplaceController>()
        .servicesFor(widget.professional.id);
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
        professionalId: widget.professional.id,
        serviceId: selected!.id,
        serviceName: selected!.name,
        category: widget.professional.category,
        scheduledDate: date,
        scheduledTime: time,
        customerAddress: address.text.trim(),
        servicePrice: selected!.priceRwf,
        district: district,
        sector: district,
      ),
    );
    if (!mounted || booking == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(bookingId: booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Book a visit')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (controller.errorMessage != null)
              ErrorBanner(message: controller.errorMessage!),
            Text(widget.professional.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Date: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final next = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  initialDate: date,
                );
                if (next != null) setState(() => date = next);
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: time,
              items: const [
                DropdownMenuItem(value: '09:00', child: Text('09:00')),
                DropdownMenuItem(value: '11:00', child: Text('11:00')),
                DropdownMenuItem(value: '14:00', child: Text('14:00')),
                DropdownMenuItem(value: '16:00', child: Text('16:00')),
              ],
              onChanged: (value) => setState(() => time = value ?? time),
              decoration: const InputDecoration(labelText: 'Time'),
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
                'Continue to payment${selected == null ? '' : ' · ${Money.rwf(selected!.priceRwf)}'}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
