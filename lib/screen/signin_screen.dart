import 'package:flutter/material.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/supabase_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Account creation. Passwords go to Supabase Auth, never to profile storage.
class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _passwordVisible = false;
  bool _submitting = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) =>
      (value?.length ?? 0) < 8 ? 'Use at least 8 characters' : null;

  String? _validateConfirmation(String? value) =>
      value != _password.text ? 'Passwords do not match' : null;

  Future<void> _createAccount() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    if (!SupabaseSettings.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Configure the local Supabase URL and publishable key '
            'to create an account.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final email = _email.text.trim().toLowerCase();
      final profileData = {
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
      };
      final result = await client.auth.signUp(
        email: email,
        password: _password.text,
        data: profileData,
      );
      final user = result.user;
      if (user == null) throw StateError('Signup did not return a user');

      if (result.session == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Check your email to confirm your account, then log in.',
            ),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      var account = await activeRepository.getAccount(user.id);
      if (account == null) {
        // Supports a local database that has not applied the profile trigger.
        await client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'first_name': _firstName.text.trim(),
          'last_name': _lastName.text.trim(),
        });
        account = await activeRepository.getAccount(user.id);
      }
      if (account == null) throw StateError('Profile was not created');
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } on AuthException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) {
        _showError('Could not create the account. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.error),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator ?? _required,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Your details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _field('First name', _firstName),
                _field('Last name', _lastName),
                _field(
                  'Email',
                  _email,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                _field(
                  'Password',
                  _password,
                  validator: _validatePassword,
                  obscure: !_passwordVisible,
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                _field(
                  'Confirm password',
                  _confirmPassword,
                  validator: _validateConfirmation,
                  obscure: !_passwordVisible,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _createAccount,
                    child: Text(
                      _submitting ? 'Creating account...' : 'Create account',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
