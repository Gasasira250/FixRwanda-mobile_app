import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/launchers.dart';
import '../widgets/app_surfaces.dart';
import '../widgets/verified_badge.dart';

class ProfessionalDetailScreen extends StatelessWidget {
  const ProfessionalDetailScreen({super.key, required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    final canBook = professional.isVerifiedProfessional;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Professional')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${professional.trade} • ${professional.location}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 12),
                VerifiedBadge(professional: professional),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                label: 'Rating',
                value: professional.rating.toStringAsFixed(1),
                accent: AppColors.sunYellow,
              ),
              _Stat(label: 'Jobs', value: '${professional.jobsCompleted}'),
              _Stat(
                label: 'From',
                value: formatRwf(professional.serviceFeeRwf),
                accent: AppColors.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final phone = rwandaContactFor(professional.id);
                    final ok = await makePhoneCall(phone);
                    if (!context.mounted) return;
                    await showLaunchResult(
                      context,
                      ok: ok,
                      fallback:
                          'Call $phone from a phone to reach this professional.',
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
                    final phone = rwandaContactFor(professional.id);
                    final ok = await sendSms(
                      phone,
                      body:
                          'Hello ${professional.name}, I found you on FixRwanda.',
                    );
                    if (!context.mounted) return;
                    await showLaunchResult(
                      context,
                      ok: ok,
                      fallback:
                          'SMS $phone from a phone to message this professional.',
                    );
                  },
                  icon: const Icon(Icons.sms_outlined),
                  label: const Text('SMS'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Verification'),
          const SizedBox(height: 8),
          Text(
            canBook
                ? 'This professional has passed ID and TVET verification and can be booked.'
                : 'This professional is still under review and cannot be booked yet.',
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            'TVET: ${professional.tvetVerified ? 'verified' : 'not verified'}  •  National ID: ${professional.idVerified ? 'verified' : 'not verified'}',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          Text(professional.about, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Services'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final service in professional.services)
                Chip(label: Text(service)),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: canBook
                ? () => Navigator.of(context).pushNamed(
                    '/booking',
                    arguments: professional,
                  )
                : null,
            child: Text(canBook ? 'Book now' : 'Not yet verified'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: accent ?? AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
