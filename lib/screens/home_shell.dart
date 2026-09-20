import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/professional.dart';
import '../repositories/professional_repository.dart';
import '../state/marketplace_controller.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/money.dart';
import '../widgets/app_states.dart';
import '../widgets/market_design.dart';
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
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: controller.isProfessional ? 'Jobs' : 'Bookings',
          ),
          const NavigationDestination(
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

  void _openSearch([String? query]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfessionalsScreen(
          initial: ProfessionalFilter(query: query ?? search.text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    final user = controller.user;
    final firstName = user?.fullName.split(' ').first ?? 'there';
    final bookable = controller.professionals
        .where((professional) => professional.isBookable)
        .take(6)
        .toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HomeHero(
          greeting: 'Muraho, $firstName',
          search: search,
          onSearch: () => _openSearch(),
          onFilter: () => _openSearch(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: const [
              TrustChip(icon: Icons.lock_rounded, label: 'Escrow, not cash'),
              SizedBox(width: 8),
              TrustChip(icon: Icons.verified_rounded, label: 'Green Badge'),
              SizedBox(width: 8),
              TrustChip(icon: Icons.near_me_rounded, label: 'Live tracking'),
              SizedBox(width: 8),
              TrustChip(icon: Icons.timer_rounded, label: '15-min offer'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isProfessional &&
                  controller.myProfessional?.isBookable != true)
                const ErrorBanner(
                  message:
                      'Complete NIDA KYC, Irembo good conduct, and a TVET/IPRC or RDB document to receive job offers.',
                ),
              SectionHeader(
                title: 'Categories',
                actionLabel: 'See all',
                onAction: () => _openSearch(),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppConstants.serviceCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.22,
                ),
                itemBuilder: (context, index) {
                  final category = AppConstants.serviceCategories[index];
                  final tint = CategoryLook.tint(category);
                  return SurfaceCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JobRequestScreen(category: category),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconWell(
                          icon: CategoryLook.icon(category),
                          color: tint,
                        ),
                        const Spacer(),
                        Text(
                          category,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Book in Kigali',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Verified professionals',
                actionLabel: 'Browse',
                onAction: () => _openSearch(),
              ),
              const SizedBox(height: 12),
              if (bookable.isEmpty)
                const EmptyState(
                  title: 'No professionals yet',
                  message: 'Check back soon or try another category.',
                )
              else
                ...bookable.map(
                  (professional) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProfessionalCard(professional: professional),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.greeting,
    required this.search,
    required this.onSearch,
    required this.onFilter,
  });

  final String greeting;
  final TextEditingController search;
  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.heroNavy],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -10,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 36,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.handyman_rounded, size: 28),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find a professional in Kigali',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 16, color: AppTheme.secondaryColor),
                        SizedBox(width: 4),
                        Text(
                          'Gasabo · Kicukiro · Nyarugenge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search plumbing, electrician, cleaning...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: onFilter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({super.key, required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    final tint = CategoryLook.tint(professional.category);
    return SurfaceCard(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/professional',
          arguments: professional.id,
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: tint.withValues(alpha: 0.14),
            child: Text(
              professional.name[0],
              style: TextStyle(
                color: tint,
                fontWeight: FontWeight.w800,
                fontSize: 20,
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${professional.category} · ${professional.sector ?? professional.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 16),
                        Text(
                          ' ${professional.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (professional.kigaliGreenBadge)
                      const KigaliGreenBadge()
                    else
                      StatusPill.verification(professional.verificationStatus),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              Money.rwf(professional.startingPrice),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
