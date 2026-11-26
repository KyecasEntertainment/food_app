import 'package:flutter/material.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/screen/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  static const double _horizontalPadding = 16.0;
  // Avatar radius (single circle)
  static const double _avatarRadius = 80.0;
  // Maximum width for input fields to avoid overly wide inputs on large screens
  static const double _inputMaxWidth = 520.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    String hint, {
    required IconData icon,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    );
    final errorBorder = border.copyWith(
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    );

    return InputDecoration(
      filled: true,
      fillColor: AppColors.card,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textPrimary),
      suffixIcon: suffix,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      errorStyle: const TextStyle(color: AppColors.textOnPrimary, fontSize: 14),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _inputMaxWidth),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            decoration: _inputDecoration(hint, icon: icon, suffix: suffix),
            validator: validator,
          ),
        ),
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      try {
        final matchedUser = await _signInWithSupabase(email, password);

        if (!mounted) return;

        if (matchedUser != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login Successful!')));
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } on AuthException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not sign in. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<UserAccounts?> _signInWithSupabase(
    String email,
    String password,
  ) async {
    final result = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user == null) return null;
    final account = await activeRepository.getAccount(user.id);
    if (account == null) {
      await Supabase.instance.client.auth.signOut();
      throw StateError('Account profile is missing');
    }
    return account;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryPressed],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Text(
                  'WELCOME',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: _avatarRadius,
                  backgroundImage: const AssetImage(
                    'assets/logo/app/ChowPremacy.png',
                  ),
                ),
                const SizedBox(height: 50),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        validator: _passwordValidator,
                        suffix: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primary,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SigninScreen(),
                          ),
                        ),
                        child: const Text(
                          'Create an account',
                          style: TextStyle(color: AppColors.textOnPrimary),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
