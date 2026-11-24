import 'dart:math';

import 'address.dart';
import 'cart_item.dart';

class OrderLine {
  final int itemId;
  final int quantity;
  final double unitPrice;

  const OrderLine({
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'quantity': quantity,
    'unit_price': unitPrice,
  };

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
    itemId: json['item_id'] as int,
    quantity: json['quantity'] as int,
    unitPrice: (json['unit_price'] as num).toDouble(),
  );
}

/// One order plus its item IDs and quantities. Address and prices are snapshots.
class FoodOrder {
  final String id;
  final String accountId;
  final List<OrderLine> items;
  final Address deliveryAddress;
  final double shippingPrice;
  final double tipPrice;
  final double totalPrice;
  final DateTime createdAt;

  FoodOrder({
    required this.id,
    required this.accountId,
    required this.items,
    required this.deliveryAddress,
    required this.shippingPrice,
    required this.tipPrice,
    required this.totalPrice,
    required this.createdAt,
  }) {
    if (items.isEmpty ||
        items.any((line) => line.quantity <= 0 || line.unitPrice < 0)) {
      throw ArgumentError(
        'An order requires items with valid quantities and prices',
      );
    }
    if (!deliveryAddress.isComplete ||
        shippingPrice < 0 ||
        tipPrice < 0 ||
        (totalPrice -
                    (items.fold<double>(0, (sum, line) => sum + line.subtotal) +
                        shippingPrice +
                        tipPrice))
                .abs() >
            0.01) {
      throw ArgumentError('Invalid order address or total');
    }
  }

  factory FoodOrder.fromCart({
    required List<CartItem> cartItems,
    required Address deliveryAddress,
    required double shippingPrice,
    double tipPrice = 0,
    required String accountId,
  }) {
    final lines = cartItems
        .map(
          (item) => OrderLine(
            itemId: item.itemId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ),
        )
        .toList(growable: false);
    return FoodOrder(
      id: _newUuid(),
      accountId: accountId,
      items: lines,
      deliveryAddress: deliveryAddress,
      shippingPrice: shippingPrice,
      tipPrice: tipPrice,
      totalPrice: lines.fold<double>(
        shippingPrice + tipPrice,
        (sum, line) => sum + line.subtotal,
      ),
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'account_id': accountId,
    'items': items.map((item) => item.toJson()).toList(),
    'delivery_address': deliveryAddress.toJson(),
    'shipping_price': shippingPrice,
    'tip_price': tipPrice,
    'total_price': totalPrice,
    'created_at': createdAt.toIso8601String(),
  };

  factory FoodOrder.fromJson(Map<String, dynamic> json) => FoodOrder(
    id: json['id'] as String,
    accountId: json['account_id'] as String,
    items: (json['items'] as List)
        .map(
          (entry) =>
              OrderLine.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList(),
    deliveryAddress: Address.fromJson(
      Map<String, dynamic>.from(json['delivery_address'] as Map),
    ),
    shippingPrice: (json['shipping_price'] as num).toDouble(),
    tipPrice: (json['tip_price'] as num?)?.toDouble() ?? 0,
    totalPrice: (json['total_price'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

String _newUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
