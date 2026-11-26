import 'package:supabase_flutter/supabase_flutter.dart';

import 'address.dart';
import 'saved_address.dart';

class SavedAddressRepository {
  static SupabaseClient get _client => Supabase.instance.client;

  static String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Sign in to manage addresses');
    return id;
  }

  static Future<List<SavedAddress>> load() async {
    final rows = await _client
        .from('saved_addresses')
        .select()
        .eq('account_id', _userId)
        .order('created_at');
    return rows.map(SavedAddress.fromJson).toList(growable: false);
  }

  static Future<void> save({
    String? id,
    required String kind,
    required String name,
    required Address address,
  }) async {
    final values = {
      'label_kind': kind,
      'name': name.trim(),
      ...address.toJson(),
    };
    if (id == null) {
      final row = await _client
          .from('saved_addresses')
          .insert({'account_id': _userId, ...values})
          .select('id')
          .single();
      final all = await load();
      if (!all.any((entry) => entry.isSelected)) {
        await select(row['id'] as String);
      }
    } else {
      await _client
          .from('saved_addresses')
          .update(values)
          .eq('id', id)
          .eq('account_id', _userId);
      final all = await load();
      if (!all.any((entry) => entry.isSelected)) {
        await select(id);
      }
    }
  }

  static Future<void> select(String id) async {
    await _client.rpc('select_saved_address', params: {'p_address_id': id});
  }
}
