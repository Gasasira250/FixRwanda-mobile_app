import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/cancellation_policy.dart';
import '../models/booking.dart';
import '../models/escrow.dart';
import '../models/payment.dart';
import '../state/marketplace_controller.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    if (controller.isProfessional) {
      return const ProviderJobsScreen();
    }
    final bookings = controller.bookings;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Your jobs',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: bookings.isEmpty
                ? const EmptyState(
                    title: 'No jobs yet',
                    message: 'Request a technician from Home. Payment stays in escrow until the technician enters the 4-digit code on your screen.',
                    icon: Icons.calendar_month_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          title: Text(booking.serviceName),
                          subtitle: Text(
                            '${booking.professionalName} · ${Money.rwf(booking.servicePrice)}',
                          ),
                          trailing: StatusPill.booking(booking.status),
                          onTap: () => Navigator.of(context).pushNamed(
                            '/booking',
                            arguments: booking.id,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProviderJobsScreen extends StatelessWidget {
  const ProviderJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Job board',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Open in my district'),
                  Tab(text: 'My jobs'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _JobList(
                      bookings: controller.openJobs,
                      empty: 'No open jobs in your district right now.',
                    ),
                    _JobList(
                      bookings: controller.assignedJobs,
                      empty: 'You have not accepted a job yet.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  const _JobList({required this.bookings, required this.empty});
  final List<Booking> bookings;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(title: 'Nothing here', message: empty);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            title: Text(booking.serviceName),
            subtitle: Text('${booking.district ?? booking.sector ?? 'Kigali'} · ${Money.rwf(booking.servicePrice)}'),
            trailing: StatusPill.booking(booking.status),
            onTap: () => Navigator.of(context).pushNamed('/booking', arguments: booking.id),
          ),
        );
      },
    );
  }
}

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final otp = TextEditingController();
  final chat = TextEditingController();
  final dispute = TextEditingController();

  @override
  void dispose() {
    otp.dispose();
    chat.dispose();
    dispute.dispose();
    super.dispose();
  }

  Booking? _find(MarketplaceController controller) {
    for (final item in [
      ...controller.bookings,
      ...controller.openJobs,
      ...controller.assignedJobs,
      ...controller.disputedJobs,
    ]) {
      if (item.id == widget.bookingId) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final booking = _find(controller);
    if (booking == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Job not found',
          message: 'This job is no longer available.',
        ),
      );
    }
    final quote = CancellationPolicy.quote(booking);
    final payment = controller.paymentFor(booking.id);
    final escrow = controller.escrowFor(booking.id);
    final isClient = !controller.isProfessional;
    final remaining = booking.broadcastExpiresAt?.difference(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('Job details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (controller.errorMessage != null)
            ErrorBanner(message: controller.errorMessage!),
          Text(booking.serviceName, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          StatusPill.booking(booking.status),
          const SizedBox(height: 12),
          Text(booking.professionalName),
          Text('${booking.district ?? 'Kigali'} · ${booking.customerAddress}'),
          Text(Money.rwf(booking.servicePrice)),
          if (payment != null) Text('Client payment: ${payment.status.name} (escrow, not cash)'),
          if (escrow != null) Text('Escrow: ${escrow.status.name}'),
          Text('Payment state: ${booking.paymentState.apiName}'),
          if (booking.platformFeeRwf > 0)
            Text('Platform fee ${Money.rwf(booking.platformFeeRwf)}'),
          if (escrow?.status == EscrowStatus.released)
            Text(
              'Payout ${Money.rwf(escrow!.providerPayoutRwf)} to professional · marketplace fee ${Money.rwf(escrow.marketplaceFeeRwf)}',
            ),
          if (booking.status == BookingStatus.broadcasting && remaining != null && remaining.isNegative == false)
            Text(
              'Current technicians have ${remaining.inMinutes} min ${remaining.inSeconds.remainder(60)} sec to accept. Round ${booking.broadcastRound}.',
            ),
          if (isClient &&
              booking.completionOtp != null &&
              (booking.status == BookingStatus.inProgress ||
                  booking.status == BookingStatus.awaitingOtp)) ...[
            const SizedBox(height: 16),
            const Text('Show this 4-digit code to the technician when the work is finished. They must enter it to receive payout.'),
            Text(
              booking.completionOtp!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
          if (booking.startJobPhotoRef != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Before photo: ${booking.startJobPhotoRef}'),
            ),
          if (booking.afterPhotoUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('After photo: ${booking.afterPhotoUrl}'),
            ),
          const SizedBox(height: 16),
          if (booking.status == BookingStatus.pending && isClient)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/payment', arguments: booking.id),
              child: const Text('Pre-authorise MoMo escrow'),
            ),
          if (booking.status == BookingStatus.broadcasting && controller.isProfessional)
            ElevatedButton(
              onPressed: () => controller.acceptJob(booking.id),
              child: const Text('Accept job'),
            ),
          if (controller.isProfessional && booking.professionalId == controller.myProfessional?.id) ...[
            if (booking.status == BookingStatus.accepted)
              ElevatedButton(
                onPressed: () => controller.startTravel(booking.id),
                child: const Text('Technician en route'),
              ),
            if (booking.status == BookingStatus.enRoute)
              ElevatedButton(
                onPressed: () => controller.markArrived(booking.id),
                child: const Text('I have arrived'),
              ),
            if (booking.status == BookingStatus.arrived)
              ElevatedButton(
                onPressed: () => controller.startJob(
                  booking.id,
                  photoRef: 'arrival-${DateTime.now().millisecondsSinceEpoch}',
                ),
                child: const Text('Start job (upload arrival photo)'),
              ),
            if (booking.status == BookingStatus.inProgress) ...[
              if (booking.afterPhotoUrl == null)
                ElevatedButton(
                  onPressed: () => controller.uploadAfterPhoto(
                    booking.id,
                    photoRef: 'after-${DateTime.now().millisecondsSinceEpoch}',
                  ),
                  child: const Text('Upload after photo'),
                ),
              TextField(
                controller: otp,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Client 4-digit code',
                ),
              ),
              ElevatedButton(
                onPressed: () => controller.markWorkFinished(
                  booking.id,
                  otp: otp.text,
                ),
                child: const Text('Enter client OTP and release payout'),
              ),
            ],
          ],
          if (booking.status == BookingStatus.enRoute ||
              booking.status == BookingStatus.arrived ||
              booking.status == BookingStatus.inProgress)
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/tracking', arguments: booking.id),
              child: const Text('Open live map tracking'),
            ),
          if (isClient && booking.status == BookingStatus.inProgress) ...[
            TextField(
              controller: dispute,
              decoration: const InputDecoration(labelText: 'Dispute reason'),
            ),
            OutlinedButton(
              onPressed: () => controller.openDispute(
                booking.id,
                reason: dispute.text,
              ),
              child: const Text('Open dispute'),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Job chat'),
          for (final message in controller.messagesFor(booking.id))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${message.senderName}: ${message.body}'),
            ),
          TextField(
            controller: chat,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          TextButton(
            onPressed: () async {
              await controller.sendJobMessage(
                bookingId: booking.id,
                body: chat.text,
              );
              chat.clear();
            },
            child: const Text('Send message'),
          ),
          if (quote.canCancel && isClient) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(quote.title),
                    content: Text(quote.message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Keep job'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Cancel and refund escrow'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await controller.cancelBooking(booking.id);
                }
              },
              child: const Text('Cancel job'),
            ),
          ],
          if (booking.status == BookingStatus.completed && isClient)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/review', arguments: booking.id),
              child: const Text('Leave a review'),
            ),
        ],
      ),
    );
  }
}
