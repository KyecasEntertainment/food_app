import 'package:supabase_flutter/supabase_flutter.dart';

import 'address.dart';
import 'cart_item.dart';
import 'local_database.dart';
import 'order.dart';
import 'product_list.dart';
import 'user_accounts.dart';

/// Transitional adapter: Auth and profiles use Supabase while the catalog,
/// cart, and orders keep their current local storage until their cutover.
class SupabaseProfileRepository implements FoodRepository {
  SupabaseProfileRepository(this._local);

  final FoodRepository _local;
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<UserAccounts?> getAccount(String id) async {
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
    final user = _client.auth.currentUser;
    if (user == null || user.id != account.id) {
      throw StateError('Sign in to update your profile');
    }
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
  Future<List<FoodItem>> getFoodItems() => _local.getFoodItems();

  @override
  Future<List<CartItem>> getCart(String accountId) => _local.getCart(accountId);

  @override
  Future<void> saveCart(String accountId, List<CartItem> items) =>
      _local.saveCart(accountId, items);

  @override
  Future<FoodOrder> saveOrder(FoodOrder order) => _local.saveOrder(order);

  @override
  Future<List<FoodOrder>> getOrders(String accountId) =>
      _local.getOrders(accountId);
}
