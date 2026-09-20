import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/marketplace_controller.dart';
import '../widgets/app_states.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int rating = 5;
  final comment = TextEditingController();

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = context.read<MarketplaceController>();
    final review = await controller.addReview(
      bookingId: widget.bookingId,
      rating: rating,
      comment: comment.text,
    );
    if (!mounted) return;
    if (review != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a review')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (controller.errorMessage != null)
              ErrorBanner(message: controller.errorMessage!),
            const Text('Only completed jobs can be reviewed, once.'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => rating = i),
                    icon: Icon(
                      i <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
              ],
            ),
            TextField(
              controller: comment,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'How was the work?',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit review'),
            ),
          ],
        ),
      ),
    );
  }
}
