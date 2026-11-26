import 'package:supabase_flutter/supabase_flutter.dart';

import 'address.dart';
import 'cart_item.dart';
import 'local_database.dart';
import 'order.dart';
import 'product_list.dart';
import 'user_accounts.dart';

/// Supabase data adapter. Dart models keep Storage object keys, not signed URLs.
class SupabaseFoodRepository implements FoodRepository {
  SupabaseClient get _client => Supabase.instance.client;

  String get _accountId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Sign in to access your account');
    return id;
  }

  void _requireAccount(String id) {
    if (id != _accountId) throw StateError('Account does not match session');
  }

  @override
  Future<UserAccounts?> getAccount(String id) async {
    _requireAccount(id);
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return UserAccounts(
      id: row['id'] as String,
      firstName: row['first_name'] as String,
      lastName: row['last_name'] as String,
      email: row['email'] as String? ?? '',
      avatar: row['avatar'] as String? ?? '',
      address: Address.fromJson(row),
    );
  }

  @override
  Future<void> saveAccount(UserAccounts account) async {
    _requireAccount(account.id);
    final user = _client.auth.currentUser!;
    if (account.email != user.email) {
      await _client.auth.updateUser(UserAttributes(email: account.email));
    }
    await _client
        .from('profiles')
        .update({
          'first_name': account.firstName,
          'last_name': account.lastName,
          'email': account.email,
          'avatar': account.avatar,
          ...account.address.toJson(),
        })
        .eq('id', account.id);
  }

  @override
  Future<List<FoodItem>> getFoodItems() async {
    final rows = await _client
        .from('food_items')
        .select('id,photo,name,price,category')
        .order('id', ascending: true);
    return rows.map(FoodItem.fromJson).toList(growable: false);
  }

  @override
  Future<List<CartItem>> getCart(String accountId) async {
    _requireAccount(accountId);
    final rows = await _client
        .from('cart_items')
        .select('item_id,quantity,food_items(name,photo,price)')
        .eq('account_id', accountId)
        .order('item_id');
    return rows
        .map((row) {
          final food = Map<String, dynamic>.from(row['food_items'] as Map);
          return CartItem(
            itemId: row['item_id'] as int,
            quantity: row['quantity'] as int,
            name: food['name'] as String,
            photo: food['photo'] as String,
            unitPrice: (food['price'] as num).toDouble(),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> saveCart(String accountId, List<CartItem> items) async {
    _requireAccount(accountId);
    await _client.rpc(
      'replace_cart',
      params: {
        'p_items': items
            .map((item) => {'item_id': item.itemId, 'quantity': item.quantity})
            .toList(),
      },
    );
  }

  @override
  Future<FoodOrder> saveOrder(FoodOrder order) async {
    _requireAccount(order.accountId);
    final id = await _client.rpc(
      'place_order',
      params: {
        'p_request_id': order.id,
        'p_items': order.items
            .map((line) => {'item_id': line.itemId, 'quantity': line.quantity})
            .toList(),
        'p_address': order.deliveryAddress.toJson(),
        'p_tip': order.tipPrice,
      },
    );
    await _client.rpc(
      'set_order_payment_method',
      params: {'p_order_id': id, 'p_payment_method': order.paymentMethod},
    );
    return _getOrder(id as String);
  }

  Future<FoodOrder> _getOrder(String id) async {
    final row = await _client
        .from('orders')
        .select('*,order_items(item_id,item_name,quantity,unit_price)')
        .eq('id', id)
        .single();
    return _mapOrder(row);
  }

  @override
  Future<List<FoodOrder>> getOrders(String accountId) async {
    _requireAccount(accountId);
    final rows = await _client
        .from('orders')
        .select('*,order_items(item_id,item_name,quantity,unit_price)')
        .eq('account_id', accountId)
        .order('created_at', ascending: false);
    return rows.map(_mapOrder).toList(growable: false);
  }

  @override
  Future<FoodOrder> updateOrderStatus(
    String accountId,
    String orderId,
    OrderStatus status,
  ) async {
    _requireAccount(accountId);
    await _client.rpc(
      'advance_order_status',
      params: {'p_order_id': orderId, 'p_status': status.name},
    );
    return _getOrder(orderId);
  }

  @override
  Future<FoodOrder> rateOrder(
    String accountId,
    String orderId, {
    required int driverRating,
    required int shopRating,
  }) async {
    _requireAccount(accountId);
    await _client.rpc(
      'rate_order',
      params: {
        'p_order_id': orderId,
        'p_driver_rating': driverRating,
        'p_shop_rating': shopRating,
      },
    );
    return _getOrder(orderId);
  }

  FoodOrder _mapOrder(Map<String, dynamic> row) => FoodOrder(
    id: row['id'] as String,
    accountId: row['account_id'] as String,
    items: (row['order_items'] as List)
        .map(
          (line) => OrderLine.fromJson(Map<String, dynamic>.from(line as Map)),
        )
        .toList(growable: false),
    deliveryAddress: Address.fromJson(row),
    shippingPrice: (row['shipping_price'] as num).toDouble(),
    tipPrice: (row['tip_price'] as num).toDouble(),
    totalPrice: (row['total_price'] as num).toDouble(),
    createdAt: DateTime.parse(row['created_at'] as String),
    status: OrderStatus.values.byName(row['status'] as String),
    preparingSeconds: row['preparing_seconds'] as int,
    deliveredAt: row['delivered_at'] == null
        ? null
        : DateTime.parse(row['delivered_at'] as String),
    driverRating: row['driver_rating'] as int?,
    shopRating: row['shop_rating'] as int?,
    paymentMethod: row['payment_method'] as String? ?? '',
  );
}
