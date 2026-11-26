import 'package:flutter/material.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/order.dart';
import 'package:food_app/screen/order_receipt_screen.dart';

class OrderRatingPage extends StatefulWidget {
  const OrderRatingPage({super.key, required this.order});

  final FoodOrder order;

  @override
  State<OrderRatingPage> createState() => _OrderRatingPageState();
}

class _OrderRatingPageState extends State<OrderRatingPage> {
  int _driverRating = 0;
  int _shopRating = 0;
  bool _saving = false;

  Future<void> _submit() async {
    if (_saving || _driverRating == 0 || _shopRating == 0) return;
    setState(() => _saving = true);
    try {
      final rated = await activeRepository.rateOrder(
        widget.order.accountId,
        widget.order.id,
        driverRating: _driverRating,
        shopRating: _shopRating,
      );
      if (mounted) Navigator.of(context).pop(rated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save ratings. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Rate your delivery')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.check_circle, size: 68, color: AppColors.success),
            const SizedBox(height: 12),
            const Text(
              'Enjoy your food.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'How was your delivery?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            _ratingCard(
              title: 'Rate your rider',
              icon: Icons.two_wheeler,
              value: _driverRating,
              onChanged: (value) => setState(() => _driverRating = value),
            ),
            const SizedBox(height: 14),
            _ratingCard(
              title: 'Rate the shop',
              icon: Icons.storefront_outlined,
              value: _shopRating,
              onChanged: (value) => setState(() => _shopRating = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving || _driverRating == 0 || _shopRating == 0
                  ? null
                  : _submit,
              child: Text(_saving ? 'Saving…' : 'Submit ratings'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OrderReceiptPage(order: widget.order),
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('View E-Receipt'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _ratingCard({
    required String title,
    required IconData icon,
    required int value,
    required ValueChanged<int> onChanged,
  }) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final star = index + 1;
            return IconButton(
              tooltip: '$star ${star == 1 ? 'star' : 'stars'}',
              onPressed: () => onChanged(star),
              icon: Icon(
                star <= value ? Icons.star_rounded : Icons.star_border_rounded,
                size: 36,
                color: AppColors.accent,
              ),
            );
          }),
        ),
      ],
    ),
  );
}
