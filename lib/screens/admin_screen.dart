import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../models/payment.dart';
import '../models/professional.dart';
import '../state/marketplace_controller.dart';
import '../widgets/app_states.dart';
import '../widgets/verification_badges.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Professional> pending = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final controller = context.read<MarketplaceController>();
    final items = await controller.pendingVerifications();
    await controller.refresh();
    if (!mounted) return;
    setState(() {
      pending = items;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin desk'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Verification'),
              Tab(text: 'Disputes'),
            ],
          ),
        ),
        body: loading
            ? const LoadingView()
            : TabBarView(
                children: [
                  _VerificationQueue(
                    pending: pending,
                    controller: controller,
                    onChanged: _load,
                  ),
                  _DisputeQueue(
                    bookings: controller.disputedJobs,
                    controller: controller,
                    onChanged: _load,
                  ),
                ],
              ),
      ),
    );
  }
}

class _VerificationQueue extends StatelessWidget {
  const _VerificationQueue({
    required this.pending,
    required this.controller,
    required this.onChanged,
  });

  final List<Professional> pending;
  final MarketplaceController controller;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) {
      return const EmptyState(
        title: 'Queue is clear',
        message: 'No professionals are waiting for review.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final professional = pending[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(professional.name, style: Theme.of(context).textTheme.titleLarge),
                Text(professional.category),
                const SizedBox(height: 8),
                VerificationBadges(professional: professional),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: professional.pipeline.documentsComplete
                            ? () async {
                                await controller.setVerification(
                                  professional.id,
                                  VerificationStatus.verified,
                                );
                                await onChanged();
                              }
                            : null,
                        child: const Text('Issue Green Badge'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await controller.setVerification(
                            professional.id,
                            VerificationStatus.rejected,
                          );
                          await onChanged();
                        },
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DisputeQueue extends StatelessWidget {
  const _DisputeQueue({
    required this.bookings,
    required this.controller,
    required this.onChanged,
  });

  final List<Booking> bookings;
  final MarketplaceController controller;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const EmptyState(
        title: 'No disputed jobs',
        message: 'Escrow disputes appear here with before/after photos and chat.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final messages = controller.messagesFor(booking.id);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.serviceName, style: Theme.of(context).textTheme.titleLarge),
                Text('${booking.professionalName} · ${booking.customerAddress}'),
                const SizedBox(height: 8),
                StatusPill.booking(booking.status),
                Text('Payment ${booking.paymentState.apiName}'),
                if (booking.disputeReason != null) Text(booking.disputeReason!),
                const SizedBox(height: 8),
                Text('Before: ${booking.beforePhotoUrl ?? 'missing'}'),
                Text('After: ${booking.afterPhotoUrl ?? 'missing'}'),
                const SizedBox(height: 8),
                const Text('Chat log'),
                for (final message in messages)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${message.senderName}: ${message.body}'),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await controller.adminRefund(booking.id);
                          await onChanged();
                        },
                        child: const Text('Manual refund'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.adminPayout(booking.id);
                          await onChanged();
                        },
                        child: const Text('Manual payout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
