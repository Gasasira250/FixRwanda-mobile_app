import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final items =
        await context.read<MarketplaceController>().pendingVerifications();
    if (!mounted) return;
    setState(() {
      pending = items;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Verification queue')),
      body: loading
          ? const LoadingView()
          : pending.isEmpty
              ? const EmptyState(
                  title: 'Queue is clear',
                  message: 'No professionals are waiting for review.',
                )
              : ListView.separated(
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
                            Text(
                              professional.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(professional.category),
                            const SizedBox(height: 8),
                            VerificationBadges(professional: professional),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await controller.setVerification(
                                        professional.id,
                                        VerificationStatus.verified,
                                      );
                                      await _load();
                                    },
                                    child: const Text('Verify'),
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
                                      await _load();
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
                ),
    );
  }
}
