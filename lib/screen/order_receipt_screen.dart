import 'package:flutter/material.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/app_navigation.dart';
import 'package:food_app/database/order.dart';

class OrderReceiptPage extends StatelessWidget {
  const OrderReceiptPage({super.key, required this.order});

  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    final localDate = order.createdAt.toLocal();
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(localDate);
    final timeLabel = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(localDate));
    final subtotal = order.items.fold<double>(
      0,
      (sum, line) => sum + line.subtotal,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('E-Receipt')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppNavigation.showHome();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Done'),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'E-Receipt',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 22),
                  _detail('Order number', order.id.toUpperCase()),
                  _detail('Placed', '$dateLabel, $timeLabel'),
                  if (order.deliveredAt != null)
                    _detail(
                      'Delivered',
                      '${MaterialLocalizations.of(context).formatMediumDate(order.deliveredAt!.toLocal())}, '
                          '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(order.deliveredAt!.toLocal()))}',
                    ),
                  _detail(
                    'Delivery address',
                    order.deliveryAddress.displayText,
                  ),
                  if (order.paymentMethod.isNotEmpty)
                    _detail('Payment method', order.paymentMethod),
                  const Divider(height: 30),
                  const Text(
                    'Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  for (final line in order.items)
                    _amount(
                      '${line.quantity} × ${line.name.isEmpty ? 'Item #${line.itemId}' : line.name}',
                      line.subtotal,
                    ),
                  const Divider(height: 24),
                  _amount('Subtotal', subtotal),
                  _amount('Delivery fee', order.shippingPrice),
                  if (order.tipPrice > 0) _amount('Rider tip', order.tipPrice),
                  const Divider(height: 24),
                  _amount('Total', order.totalPrice, bold: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _amount(String label, double amount, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: bold ? AppColors.primary : AppColors.textPrimary,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
