import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/professional_repository.dart';
import '../state/marketplace_controller.dart';
import '../widgets/app_states.dart';
import 'home_shell.dart';

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key, this.initial});

  final ProfessionalFilter? initial;

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  late ProfessionalFilter filter;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    filter = widget.initial ?? const ProfessionalFilter();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => loading = true);
    await context.read<MarketplaceController>().applyFilter(filter);
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(filter.category ?? 'Professionals'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Verified only'),
                  selected: filter.verifiedOnly,
                  onSelected: (value) {
                    filter = filter.copyWith(verifiedOnly: value);
                    _load();
                  },
                ),
                FilterChip(
                  label: const Text('4.5+ rating'),
                  selected: filter.minRating == 4.5,
                  onSelected: (value) {
                    filter = ProfessionalFilter(
                      query: filter.query,
                      category: filter.category,
                      location: filter.location,
                      minRating: value ? 4.5 : null,
                      maxPrice: filter.maxPrice,
                      verifiedOnly: filter.verifiedOnly,
                      sort: filter.sort,
                    );
                    _load();
                  },
                ),
                DropdownButton<ProfessionalSort>(
                  value: filter.sort,
                  items: const [
                    DropdownMenuItem(
                      value: ProfessionalSort.rating,
                      child: Text('Top rated'),
                    ),
                    DropdownMenuItem(
                      value: ProfessionalSort.priceLow,
                      child: Text('Price: low'),
                    ),
                    DropdownMenuItem(
                      value: ProfessionalSort.priceHigh,
                      child: Text('Price: high'),
                    ),
                    DropdownMenuItem(
                      value: ProfessionalSort.jobs,
                      child: Text('Most jobs'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    filter = filter.copyWith(sort: value);
                    _load();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const LoadingView(message: 'Finding professionals...')
                : controller.professionals.isEmpty
                    ? const EmptyState(
                        title: 'No matches',
                        message:
                            'Try another category, location, or remove a filter.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.professionals.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return ProfessionalCard(
                            professional: controller.professionals[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
