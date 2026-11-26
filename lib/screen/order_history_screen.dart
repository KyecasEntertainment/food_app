import 'package:flutter/material.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/order.dart';
import 'package:food_app/screen/delivery_screen.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key, required this.accountId});

  final String accountId;

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<FoodOrder>> _orders = _load();

  Future<List<FoodOrder>> _load() =>
      activeRepository.getOrders(widget.accountId);

  Future<void> _refresh() async {
    setState(() => _orders = _load());
    await _orders;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My orders')),
    body: FutureBuilder<List<FoodOrder>>(
      future: _orders,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: _refresh,
              child: const Text('Could not load orders. Tap to retry.'),
            ),
          );
        }
        final orders = snapshot.data ?? const <FoodOrder>[];
        if (orders.isEmpty) {
          return const Center(child: Text('No orders yet.'));
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Material(
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: ListTile(
                      title: Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                      ),
                      subtitle: Text(
                        '${order.status.name[0].toUpperCase()}${order.status.name.substring(1)} · '
                        '${MaterialLocalizations.of(context).formatMediumDate(order.createdAt.toLocal())}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OrderTrackingPage(order: order),
                          ),
                        );
                        if (context.mounted) _refresh();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
