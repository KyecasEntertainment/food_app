import 'user_accounts.dart';
import 'local_database.dart';

/// Temporary local sign-in fixture. Replace this entire adapter with
/// Supabase Auth; profile and order storage never contain passwords.
class DemoAuth {
  static const _passwords = <String, String>{
    'johndoe@example.com': '12345678',
    'janedoe@example.com': '87654321',
    'bob@example.com': 'password123',
    'alice@example.com': 'alice2025',
    'michael@example.com': 'mikeSecure1',
    'sarah@example.com': 'sarahPass99',
    'david@example.com': 'davidKey88',
    'emily@example.com': 'emilySafe00',
    'kevin@example.com': 'kevinLogins22',
    'sophia@example.com': 'sophiaPass33',
  };

  static Future<UserAccounts?> signIn(String email, String password) async {
    for (final account in accounts) {
      if (_passwords[account.email] != password) continue;
      final saved = await LocalDatabase.instance.getAccount(account.id);
      if (saved?.email.toLowerCase() == email.toLowerCase()) return saved;
    }
    return null;
  }
}
