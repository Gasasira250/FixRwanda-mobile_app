import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/professional.dart';
import '../models/review.dart';
import '../models/service.dart';
import '../state/marketplace_controller.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';
import '../widgets/verification_badges.dart';
import 'booking_form_screen.dart';

class ProfessionalDetailScreen extends StatefulWidget {
  const ProfessionalDetailScreen({super.key, required this.professionalId});

  final String professionalId;

  @override
  State<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  Professional? professional;
  List<Service> services = const [];
  List<Review> reviews = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final controller = context.read<MarketplaceController>();
    final found = await controller.professionalById(widget.professionalId);
    final nextReviews = await controller.reviewsFor(widget.professionalId);
    if (!mounted) return;
    setState(() {
      professional = found;
      services = found == null
          ? const []
          : controller.servicesFor(found.id);
      reviews = nextReviews;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingView());
    }
    final item = professional;
    if (item == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Not found',
          message: 'This professional is no longer available.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(item.category, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('${item.sector ?? item.location} · ${item.completedJobs} jobs'),
          const SizedBox(height: 12),
          VerificationBadges(professional: item),
          const SizedBox(height: 16),
          Text(item.description),
          const SizedBox(height: 20),
          Text('Services', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...services.map(
            (service) => Card(
              child: ListTile(
                title: Text(service.name),
                subtitle: Text(service.description),
                trailing: Text(Money.rwf(service.priceRwf)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            const Text('No reviews yet. Completed jobs can be reviewed.')
          else
            ...reviews.map(
              (review) => ListTile(
                leading: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                title: Text('${review.rating}/5'),
                subtitle: Text(review.comment),
              ),
            ),
          const SizedBox(height: 24),
          if (!item.isBookable)
            const ErrorBanner(
              message:
                  'This professional is still under verification and cannot be booked yet.',
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BookingFormScreen(professional: item),
                  ),
                );
              },
              child: const Text('Book this professional'),
            ),
        ],
      ),
    );
  }
}
