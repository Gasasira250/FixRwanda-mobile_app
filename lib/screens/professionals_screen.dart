import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/professional_card.dart';

class ProfessionalsArgs {
  const ProfessionalsArgs({this.trade, this.query});

  final String? trade;
  final String? query;
}

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key, required this.args});

  final ProfessionalsArgs args;

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  late final TextEditingController _search;
  List<Professional> _results = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.args.query ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final app = FixRwandaScope.of(context);
    final results = await app.api.fetchProfessionals(
      trade: widget.args.trade,
      query: _search.text,
    );
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.args.trade ?? 'Professionals';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Filter by name, area or skill',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.tune),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(
                    child: Text(
                      'No professionals match that search.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final professional = _results[index];
                      return ProfessionalCard(
                        professional: professional,
                        wide: true,
                        onViewProfile: () {
                          Navigator.of(context).pushNamed(
                            '/professional',
                            arguments: professional,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
