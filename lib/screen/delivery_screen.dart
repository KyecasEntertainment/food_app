import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/order.dart';
import 'package:food_app/screen/order_rating_screen.dart';
import 'package:food_app/screen/order_receipt_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key, required this.order});

  final FoodOrder order;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late FoodOrder _order = widget.order;
  Timer? _timer;
  bool _updating = false;

  int get _remainingSeconds {
    final milliseconds = _order.createdAt
        .add(Duration(seconds: _order.preparingSeconds))
        .difference(DateTime.now().toUtc())
        .inMilliseconds;
    return math.max(0, (milliseconds / 1000).ceil());
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    if (_order.status == OrderStatus.preparing) {
      setState(() {});
      if (_remainingSeconds == 0 && !_updating) _advanceToDelivering();
    }
  }

  Future<void> _advanceToDelivering() async {
    setState(() => _updating = true);
    try {
      final updated = await activeRepository.updateOrderStatus(
        _order.accountId,
        _order.id,
        OrderStatus.delivering,
      );
      if (mounted) setState(() => _order = updated);
    } catch (_) {
      // A server clock can lag a phone clock. The next tick retries.
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _markDelivered() async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      final updated = await activeRepository.updateOrderStatus(
        _order.accountId,
        _order.id,
        OrderStatus.delivered,
      );
      if (!mounted) return;
      setState(() => _order = updated);
      await _openRating();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not confirm delivery. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _openRating() async {
    final rated = await Navigator.of(context).push<FoodOrder>(
      MaterialPageRoute(builder: (_) => OrderRatingPage(order: _order)),
    );
    if (!mounted || rated == null) return;
    setState(() => _order = rated);
    _openReceipt();
  }

  void _openReceipt() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrderReceiptPage(order: _order)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Track delivery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _mapCard(),
                const SizedBox(height: 16),
                _statusCard(),
                const SizedBox(height: 16),
                _orderCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapCard() {
    final address = _order.deliveryAddress;
    final pin = LatLng(address.latitude!, address.longitude!);
    final supportsMap =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 285,
            child: supportsMap
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      GoogleMap(
                        key: ValueKey(_order.id),
                        initialCameraPosition: CameraPosition(
                          target: pin,
                          zoom: 16,
                        ),
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                      const IgnorePointer(child: _PulsingAddressPin()),
                    ],
                  )
                : const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your delivery address',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        address.displayText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    final status = _order.status;
    final title = switch (status) {
      OrderStatus.preparing => 'Preparing',
      OrderStatus.delivering => 'Delivering',
      OrderStatus.delivered => 'Delivered',
    };
    final description = switch (status) {
      OrderStatus.preparing => 'Shop is preparing your food',
      OrderStatus.delivering => 'Rider is delivering your food',
      OrderStatus.delivered => 'Enjoy your food.',
    };
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (status == OrderStatus.preparing) ...[
            const SizedBox(height: 6),
            Text(
              _remainingSeconds > 0
                  ? 'About $_remainingSeconds seconds remaining'
                  : 'Finishing preparation…',
              style: const TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              _step('Preparing', Icons.restaurant, 0),
              _connector(status.index > 0),
              _step('Delivering', Icons.two_wheeler, 1),
              _connector(status.index > 1),
              _step('Delivered', Icons.check, 2),
            ],
          ),
          if (status == OrderStatus.delivering) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updating ? null : _markDelivered,
              child: Text(_updating ? 'Confirming…' : 'Order received'),
            ),
          ],
          if (status == OrderStatus.delivered) ...[
            const SizedBox(height: 24),
            if (_order.driverRating == null || _order.shopRating == null) ...[
              ElevatedButton.icon(
                onPressed: _openRating,
                icon: const Icon(Icons.star_outline),
                label: const Text('Rate rider and shop'),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _openReceipt,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('View E-Receipt'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _step(String label, IconData icon, int index) {
    final active = _order.status.index >= index;
    return Column(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: active ? AppColors.primary : AppColors.surface,
          child: Icon(
            icon,
            color: active ? AppColors.textOnPrimary : AppColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _connector(bool active) => Expanded(
    child: Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
      color: active ? AppColors.primary : AppColors.border,
    ),
  );

  Widget _orderCard() {
    final subtotal = _order.items.fold<double>(
      0,
      (total, item) => total + item.subtotal,
    );
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order #${_order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          for (final item in _order.items)
            _amountRow(
              '${item.quantity} × ${item.name.isEmpty ? 'Item #${item.itemId}' : item.name}',
              item.subtotal,
            ),
          const Divider(height: 20),
          _amountRow('Subtotal', subtotal),
          _amountRow('Delivery fee', _order.shippingPrice),
          if (_order.tipPrice > 0) _amountRow('Rider tip', _order.tipPrice),
          const Divider(height: 20),
          _amountRow('Total', _order.totalPrice, bold: true),
        ],
      ),
    );
  }

  Widget _amountRow(String label, double amount, {bool bold = false}) =>
      Padding(
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
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: bold ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class _PulsingAddressPin extends StatefulWidget {
  const _PulsingAddressPin();

  @override
  State<_PulsingAddressPin> createState() => _PulsingAddressPinState();
}

class _PulsingAddressPinState extends State<_PulsingAddressPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 132,
    height: 132,
    child: AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => CustomPaint(
        painter: _SignalPainter(_pulse.value),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.card, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.person, color: AppColors.card, size: 25),
          ),
        ),
      ),
    ),
  );
}

class _SignalPainter extends CustomPainter {
  const _SignalPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final phase in [progress, (progress + 0.5) % 1]) {
      final eased = Curves.easeOut.transform(phase);
      final paint = Paint()
        ..color = AppColors.primary.withValues(alpha: (1 - phase) * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, 26 + eased * 36, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignalPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
