import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_surfaces.dart';
import '../widgets/professional_card.dart';
import '../widgets/service_card.dart';
import 'account_screen.dart';
import 'bookings_screen.dart';
import 'professionals_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), BookingsScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) => setState(() => _index = value),
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.muted,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
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
  final _search = TextEditingController();
  List<ServiceCategory> _categories = const [];
  List<Professional> _professionals = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({String? query}) async {
    final app = FixRwandaScope.of(context);
    final categories = await app.api.fetchCategories();
    final professionals = await app.api.fetchProfessionals(query: query);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _professionals = professionals
          .where((item) => item.isVerifiedProfessional)
          .toList();
      _loading = false;
    });
  }

  void _openProfessionals({String? trade, String? query}) {
    Navigator.of(context).pushNamed(
      '/professionals',
      arguments: ProfessionalsArgs(trade: trade, query: query),
    );
  }

  void _openProfessional(Professional professional) {
    Navigator.of(context).pushNamed('/professional', arguments: professional);
  }

  @override
  Widget build(BuildContext context) {
    final app = FixRwandaScope.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final fullName = app.customer?.name ?? 'there';
        final name = fullName.split(' ').first;
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () => _load(query: _search.text),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.skyDark, AppColors.primaryBlue],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, $name',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Find a verified professional near you',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFD6E6F7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.sunYellow,
                              child: Icon(
                                Icons.person,
                                color: AppColors.skyDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _search,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) =>
                              _openProfessionals(query: value),
                          decoration: InputDecoration(
                            hintText: 'Search plumber, electrician, Kigali...',
                            hintStyle: const TextStyle(color: AppColors.muted),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.sunYellow,
                                foregroundColor: AppColors.skyDark,
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              onPressed: () =>
                                  _openProfessionals(query: _search.text),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(title: 'Services'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 102,
                  child: _loading && _categories.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == _categories.length - 1 ? 0 : 12,
                              ),
                              child: ServiceCard(
                                category: category,
                                onTap: () =>
                                    _openProfessionals(trade: category.name),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(title: 'Verified near you'),
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_professionals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'No verified professionals yet.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                else
                  SizedBox(
                    height: 232,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: _professionals.length,
                      itemBuilder: (context, index) {
                        final professional = _professionals[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == _professionals.length - 1 ? 0 : 12,
                          ),
                          child: ProfessionalCard(
                            professional: professional,
                            onViewProfile: () =>
                                _openProfessional(professional),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
