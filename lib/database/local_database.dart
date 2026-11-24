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
  Future<void> saveOrder(FoodOrder order);
  Future<List<FoodOrder>> getOrders(String accountId);
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
  Future<void> saveOrder(FoodOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_orderPrefix${order.accountId}';
    final saved = prefs.getString(key);
    final orders = saved == null ? <dynamic>[] : jsonDecode(saved) as List;
    orders.add(order.toJson());
    await prefs.setString(key, jsonEncode(orders));
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
}

/// Set this once during app startup when a Supabase adapter is available.
FoodRepository activeRepository = LocalDatabase.instance;
