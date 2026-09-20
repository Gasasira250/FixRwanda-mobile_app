import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/professional.dart';
import '../repositories/professional_repository.dart';
import '../state/marketplace_controller.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';
import '../widgets/verification_badges.dart';
import 'account_screen.dart';
import 'bookings_screen.dart';
import 'job_request_screen.dart';
import 'professionals_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const BookingsScreen(),
      const AccountScreen(),
    ];
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: controller.isProfessional ? 'Jobs' : 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final user = controller.user;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            'Muraho${user == null ? '' : ', ${user.fullName.split(' ').first}'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Find a professional in Kigali',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (controller.isProfessional &&
              controller.myProfessional?.isBookable != true)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ErrorBanner(
                message:
                    'Complete NIDA KYC, Irembo good conduct, and a TVET/IPRC or RDB document to receive job offers.',
              ),
            ),
          TextField(
            controller: search,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfessionalsScreen(
                    initial: ProfessionalFilter(query: value),
                  ),
                ),
              );
            },
            decoration: InputDecoration(
              hintText: 'Search plumbing, electrician, cleaning...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfessionalsScreen(
                        initial: ProfessionalFilter(query: search.text),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppConstants.serviceCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final category = AppConstants.serviceCategories[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JobRequestScreen(category: category),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_iconFor(category), color: AppTheme.primaryColor),
                        const Spacer(),
                        Text(
                          category,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Verified professionals',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (controller.professionals.isEmpty)
            const EmptyState(
              title: 'No professionals yet',
              message: 'Check back soon or try another category.',
            )
          else
            ...controller.professionals
                .where((professional) => professional.isBookable)
                .take(6)
                .map(
                  (professional) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProfessionalCard(professional: professional),
                  ),
                ),
        ],
      ),
    );
  }
}

IconData _iconFor(String category) {
  return switch (category) {
    'Electrical Installation' => Icons.electrical_services_rounded,
    'Plumbing' => Icons.plumbing_rounded,
    'House Cleaning' => Icons.cleaning_services_rounded,
    'Appliance Repair' => Icons.kitchen_rounded,
    'Computer & IT Support' => Icons.computer_rounded,
    'Car Repair' => Icons.car_repair_rounded,
    'Painting' => Icons.format_paint_rounded,
    'Construction' => Icons.construction_rounded,
    'Hair Styling' => Icons.content_cut_rounded,
    'Beauty Services' => Icons.spa_rounded,
    _ => Icons.handyman_rounded,
  };
}

class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({super.key, required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/professional',
            arguments: professional.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Text(
                  professional.name[0],
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${professional.category} · ${professional.sector ?? professional.location}',
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                        Text(' ${professional.rating}'),
                        if (professional.kigaliGreenBadge)
                          const KigaliGreenBadge()
                        else
                          StatusPill.verification(professional.verificationStatus),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'From ${Money.rwf(professional.startingPrice)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
