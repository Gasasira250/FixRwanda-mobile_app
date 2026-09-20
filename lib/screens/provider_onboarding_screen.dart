import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/professional.dart';
import '../models/provider_verification.dart';
import '../state/marketplace_controller.dart';
import '../widgets/app_states.dart';
import '../widgets/verification_badges.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  final nida = TextEditingController();
  String? selfieRef;
  TradeCertificateKind tradeKind = TradeCertificateKind.tvetIprc;

  @override
  void dispose() {
    nida.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final professional = controller.myProfessional;
    if (professional == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Provider profile missing',
          message: 'Sign in with a professional account to continue onboarding.',
        ),
      );
    }
    final pipeline = professional.pipeline;
    return Scaffold(
      appBar: AppBar(title: const Text('Provider verification')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (controller.errorMessage != null)
            ErrorBanner(message: controller.errorMessage!),
          Text(
            professional.kigaliGreenBadge
                ? 'Kigali Green Badge is active. You can receive job offers.'
                : 'Complete NIDA KYC, an Irembo Good Conduct Certificate, and a trade document to receive the Kigali Green Badge.',
          ),
          const SizedBox(height: 12),
          VerificationBadges(professional: professional),
          if (professional.kigaliGreenBadge) ...[
            const SizedBox(height: 12),
            const KigaliGreenBadge(),
          ],
          const SizedBox(height: 24),
          _StepCard(
            title: '1. National ID (NIDA OCR / Smile ID)',
            status: pipeline.nidaKycPassed
                ? VerificationStatus.verified
                : pipeline.nidaStatus,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nida,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    labelText: '16-digit NIDA number',
                    hintText: '1199580000000000',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => setState(() {
                    selfieRef =
                        'liveness-${DateTime.now().millisecondsSinceEpoch}';
                  }),
                  child: Text(
                    selfieRef == null
                        ? 'Capture selfie liveness'
                        : 'Liveness selfie captured',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.busy
                      ? null
                      : () => controller.submitNidaKyc(
                            nidaNumber: nida.text,
                            selfieRef: selfieRef ?? '',
                          ),
                  child: const Text('Run Smile ID KYC'),
                ),
              ],
            ),
          ),
          _StepCard(
            title: '2. Irembo Good Conduct Certificate',
            status: pipeline.iremboStatus,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Upload the criminal record check issued through IremboGov.',
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.busy
                      ? null
                      : () => controller.submitIremboCertificate(
                            documentRef:
                                'irembo-${professional.id}-${DateTime.now().millisecondsSinceEpoch}',
                          ),
                  child: const Text('Upload Irembo certificate'),
                ),
                if (pipeline.iremboCertUrl != null)
                  Text(pipeline.iremboCertUrl!),
              ],
            ),
          ),
          _StepCard(
            title: '3. Trade certification',
            status: pipeline.tradeStatus,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<TradeCertificateKind>(
                  initialValue: tradeKind,
                  items: [
                    for (final kind in TradeCertificateKind.values)
                      DropdownMenuItem(value: kind, child: Text(kind.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => tradeKind = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Document type',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.busy
                      ? null
                      : () => controller.submitTradeCertificate(
                            kind: tradeKind,
                            documentRef:
                                'trade-${tradeKind.apiName}-${professional.id}',
                          ),
                  child: const Text('Upload trade document'),
                ),
                if (pipeline.tradeCertUrl != null) Text(pipeline.tradeCertUrl!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.status,
    required this.child,
  });

  final String title;
  final VerificationStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusPill.verification(status),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
