import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'cart_item.dart';
import 'order.dart';
import 'product_list.dart';
import 'user_accounts.dart';

/// The UI talks to this interface; a Supabase adapter can implement it later.
abstract class FoodRepository {
  Future<UserAccounts?> getAccount(String id);
  Future<void> saveAccount(UserAccounts account);
  Future<List<FoodItem>> getFoodItems();
  Future<List<CartItem>> getCart(String accountId);
  Future<void> saveCart(String accountId, List<CartItem> items);
  Future<FoodOrder> saveOrder(FoodOrder order);
  Future<List<FoodOrder>> getOrders(String accountId);
  Future<FoodOrder> updateOrderStatus(
    String accountId,
    String orderId,
    OrderStatus status,
  );
  Future<FoodOrder> rateOrder(
    String accountId,
    String orderId, {
    required int driverRating,
    required int shopRating,
  });
}

class LocalDatabase implements FoodRepository {
  LocalDatabase._();
  static final instance = LocalDatabase._();

  static const _accountPrefix = 'accounts_v1_';
  static const _cartPrefix = 'cart_v1_';
  static const _orderPrefix = 'orders_v1_';

  @override
  Future<UserAccounts?> getAccount(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('$_accountPrefix$id');
    if (saved != null) {
      return UserAccounts.fromJson(
        Map<String, dynamic>.from(jsonDecode(saved) as Map),
      );
    }
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  @override
  Future<void> saveAccount(UserAccounts account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_accountPrefix${account.id}',
      jsonEncode(account.toJson()),
    );
  }

  @override
  Future<List<FoodItem>> getFoodItems() async => List.unmodifiable(products);

  @override
  Future<List<CartItem>> getCart(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('$_cartPrefix$accountId');
    if (saved == null) return [];
    return (jsonDecode(saved) as List)
        .map(
          (entry) => CartItem.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  @override
  Future<void> saveCart(String accountId, List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_cartPrefix$accountId',
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<FoodOrder> saveOrder(FoodOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_orderPrefix${order.accountId}';
    final saved = prefs.getString(key);
    final orders = saved == null ? <dynamic>[] : jsonDecode(saved) as List;
    orders.add(order.toJson());
    await prefs.setString(key, jsonEncode(orders));
    return order;
  }

  @override
  Future<List<FoodOrder>> getOrders(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('$_orderPrefix$accountId');
    if (saved == null) return [];
    return (jsonDecode(saved) as List)
        .map(
          (entry) =>
              FoodOrder.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  Future<FoodOrder> _replaceOrder(
    String accountId,
    String orderId,
    FoodOrder Function(FoodOrder) change,
  ) async {
    final orders = await getOrders(accountId);
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index < 0) throw StateError('Order not found');
    final updated = change(orders[index]);
    orders[index] = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_orderPrefix$accountId',
      jsonEncode(orders.map((order) => order.toJson()).toList()),
    );
    return updated;
  }

  @override
  Future<FoodOrder> updateOrderStatus(
    String accountId,
    String orderId,
    OrderStatus status,
  ) => _replaceOrder(accountId, orderId, (order) {
    if (status == OrderStatus.delivering &&
        order.status == OrderStatus.preparing &&
        DateTime.now().toUtc().isBefore(
          order.createdAt.add(Duration(seconds: order.preparingSeconds)),
        )) {
      throw StateError('The shop is still preparing this order');
    }
    if ((status == OrderStatus.delivering &&
            order.status != OrderStatus.preparing) ||
        (status == OrderStatus.delivered &&
            order.status != OrderStatus.delivering) ||
        status == OrderStatus.preparing) {
      throw StateError('Invalid order status transition');
    }
    return order.copyWith(
      status: status,
      deliveredAt: status == OrderStatus.delivered
          ? DateTime.now().toUtc()
          : null,
    );
  });

  @override
  Future<FoodOrder> rateOrder(
    String accountId,
    String orderId, {
    required int driverRating,
    required int shopRating,
  }) => _replaceOrder(accountId, orderId, (order) {
    if (order.status != OrderStatus.delivered ||
        order.driverRating != null ||
        order.shopRating != null) {
      throw StateError('This order cannot be rated');
    }
    return order.copyWith(driverRating: driverRating, shopRating: shopRating);
  });
}

/// Set this once during app startup when a Supabase adapter is available.
FoodRepository activeRepository = LocalDatabase.instance;
