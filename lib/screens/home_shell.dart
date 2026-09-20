import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/broadcast_router.dart';
import '../models/booking.dart';
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

  void _openSearch([String? query, String? location]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfessionalsScreen(
          initial: ProfessionalFilter(
            query: query ?? search.text,
            location: location,
          ),
        ),
      ),
    );
  }

  Booking? _activeBooking(MarketplaceController controller) {
    final open = controller.bookings.where(
      (item) =>
          item.status != BookingStatus.completed &&
          item.status != BookingStatus.cancelled &&
          item.status != BookingStatus.expired,
    );
    if (open.isEmpty) return null;
    return open.first;
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
    final active = _activeBooking(controller);

    return AtmosphereBackdrop(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _HomeHero(
            greeting: 'Muraho, $firstName',
            search: search,
            onSearch: () => _openSearch(),
            onFilter: () => _openSearch(),
          ),
          const SizedBox(height: 14),
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.isProfessional &&
                    controller.myProfessional?.isBookable != true)
                  const ErrorBanner(
                    message:
                        'Complete NIDA KYC, Irembo good conduct, and a TVET/IPRC or RDB document to receive job offers.',
                  ),
                if (active != null) ...[
                  ActiveJobBanner(
                    title: active.serviceName,
                    subtitle:
                        '${active.professionalName} · ${active.status.name}',
                    onOpen: () => Navigator.of(context).pushNamed(
                      '/booking',
                      arguments: active.id,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                SectionHeader(
                  title: 'Kigali districts',
                  subtitle: 'Gasabo · Kicukiro · Nyarugenge',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final district in kigaliDistricts) ...[
                        DistrictPill(
                          label: district,
                          onTap: () => _openSearch(null, district),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionHeader(
                  title: 'How it works',
                  subtitle: 'Book, hold payment, track, confirm with OTP',
                ),
                const SizedBox(height: 10),
                const JourneyStrip(),
                const SizedBox(height: 22),
                SectionHeader(
                  title: 'Categories',
                  subtitle: 'Pick a trade and request a technician',
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
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final category = AppConstants.serviceCategories[index];
                    return SoftCategoryTile(
                      category: category,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                JobRequestScreen(category: category),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Verified professionals',
                  subtitle: 'Green Badge technicians ready in Kigali',
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
      ),
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
          colors: [
            AppTheme.primaryColor,
            AppTheme.heroNavy,
            Color(0xFF012A5C),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 22,
            top: 42,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.handyman_rounded, size: 30),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
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
                    'Find a professional\nin Kigali',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Gasabo · Kicukiro · Nyarugenge',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tint.withValues(alpha: 0.35), width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: tint.withValues(alpha: 0.14),
                  child: Text(
                    professional.name[0],
                    style: TextStyle(
                      color: tint,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${professional.category} · ${professional.district}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
              Text(
                ' ${professional.rating}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: Text(
                  ' · ${professional.completedJobs} jobs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                Money.rwf(professional.startingPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          if (professional.kigaliGreenBadge) ...[
            const SizedBox(height: 8),
            const KigaliGreenBadge(),
          ] else ...[
            const SizedBox(height: 8),
            StatusPill.verification(professional.verificationStatus),
          ],
        ],
      ),
    );
  }
}
