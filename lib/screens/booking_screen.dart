import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/professional.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/location.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.professional});

  final Professional professional;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late String _service;
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _location = TextEditingController(text: 'Kigali');
  late final TextEditingController _description;
  bool _summary = false;

  @override
  void initState() {
    super.initState();
    _service = widget.professional.services.first;
    final now = DateTime.now().add(const Duration(days: 1));
    _date = DateTime(now.year, now.month, now.day);
    _description = TextEditingController(
      text: 'Need ${widget.professional.trade.toLowerCase()} help at my house.',
    );
  }

  @override
  void dispose() {
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  DateTime get _scheduledAt =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  BookingDraft get _draft => BookingDraft(
    professionalId: widget.professional.id,
    professionalName: widget.professional.name,
    trade: widget.professional.trade,
    service: _service,
    scheduledAt: _scheduledAt,
    location: _location.text.trim(),
    description: _description.text.trim(),
    serviceFeeRwf: widget.professional.serviceFeeRwf,
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _useCurrentLocation() async {
    try {
      final position = await getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _location.text = 'Near ${position.label}, Rwanda';
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_summary ? 'Booking summary' : 'Book service'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            widget.professional.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.professional.location,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          if (!_summary) ...[
            const Text('Service', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _service,
              items: [
                for (final service in widget.professional.services)
                  DropdownMenuItem(value: service, child: Text(service)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _service = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(formatShortDate(_date)),
              trailing: const Icon(Icons.event),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Time'),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.schedule),
              onTap: _pickTime,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _location,
              decoration: InputDecoration(
                labelText: 'Location',
                suffixIcon: IconButton(
                  tooltip: 'Use current location',
                  icon: const Icon(Icons.my_location),
                  onPressed: _useCurrentLocation,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Job details'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => setState(() => _summary = true),
              child: const Text('Review booking'),
            ),
          ] else ...[
            _Line(label: 'Service', value: _service),
            _Line(label: 'When', value: formatDateTime(_scheduledAt)),
            _Line(label: 'Where', value: _location.text),
            _Line(label: 'Details', value: _description.text),
            _Line(
              label: 'Fee',
              value: formatRwf(widget.professional.serviceFeeRwf),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed(
                '/payment',
                arguments: _draft,
              ),
              child: const Text('Continue to payment'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() => _summary = false),
              child: const Text('Edit details'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
