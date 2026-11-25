import 'package:flutter/material.dart';
import 'package:food_app/screen/menu_screen.dart';
import 'package:food_app/screen/search_screen.dart';
import 'package:food_app/screen/cart_screen.dart';
import 'package:food_app/screen/profile_screen.dart';
import 'package:food_app/bottom_nav_bar.dart';
import 'package:food_app/screen/login_screen.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/supabase_food_repository.dart';
import 'package:food_app/database/supabase_settings.dart';
import 'package:food_app/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseSettings.isConfigured) {
    await Supabase.initialize(
      url: SupabaseSettings.url,
      publishableKey: SupabaseSettings.publishableKey,
    );
    activeRepository = SupabaseFoodRepository();
  }
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kyecas: Food Delivery App',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.surface,
          onPrimaryContainer: AppColors.textPrimary,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.surface,
          onSecondaryContainer: AppColors.textPrimary,
          tertiary: AppColors.info,
          onTertiary: AppColors.textOnPrimary,
          tertiaryContainer: AppColors.surface,
          onTertiaryContainer: AppColors.textPrimary,
          surface: AppColors.card,
          surfaceContainerLowest: AppColors.card,
          surfaceContainerLow: AppColors.background,
          surfaceContainer: AppColors.surface,
          surfaceContainerHigh: AppColors.surface,
          surfaceContainerHighest: AppColors.surface,
          onPrimary: AppColors.textOnPrimary,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.border,
          outlineVariant: AppColors.border,
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          errorContainer: AppColors.surface,
          onErrorContainer: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        dividerColor: AppColors.border,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
        ),
        cardColor: AppColors.card,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
            .apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: AppColors.textPrimary),
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? AppColors.primaryPressed
                  : AppColors.primary,
            ),
            foregroundColor: const WidgetStatePropertyAll(
              AppColors.textOnPrimary,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: SupabaseSettings.isConfigured
          ? const _AuthGate()
          : const _MissingBackendSettings(),
    );
  }
}

class _MissingBackendSettings extends StatelessWidget {
  const _MissingBackendSettings();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Local Supabase is not configured. Run the app with '
          'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY Dart defines.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<UserAccounts?> _profile = _loadProfile();

  Future<UserAccounts?> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user == null ? null : activeRepository.getAccount(user.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<UserAccounts?>(
    future: _profile,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load your account.'),
                TextButton(
                  onPressed: () => setState(() => _profile = _loadProfile()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      final account = snapshot.data;
      if (account == null && Supabase.instance.client.auth.currentUser != null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your account profile is missing.'),
                TextButton(
                  onPressed: () => setState(() => _profile = _loadProfile()),
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                      if (mounted) setState(() => _profile = _loadProfile());
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not sign out.')),
                        );
                      }
                    }
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        );
      }
      return account == null
          ? const LoginScreen()
          : MainScreen(loggedInUser: account);
    },
  );
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MainScreen extends StatefulWidget {
  final UserAccounts? loggedInUser;

  const MainScreen({super.key, this.loggedInUser});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _cartLoading = true;
  late final CartManager _cartManager = CartManager(
    accountId: widget.loggedInUser?.id,
  );

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _buildPages();
  }

  Future<void> _loadCart() async {
    await _cartManager.load();
    if (mounted) setState(() => _cartLoading = false);
  }

  void _buildPages() {
    _pages = [
      HomePage(
        loggedInUser: widget.loggedInUser,
        cartManager: _cartManager,
        onCartPressed: _openCart,
      ),
      SearchPage(
        loggedInUser: widget.loggedInUser,
        cartManager: _cartManager,
        onCartPressed: _openCart,
      ),
      ProfilePage(
        loggedInUser: widget.loggedInUser,
        onCartPressed: _openCart,
        cartManager: _cartManager,
      ),
    ];
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CartPage(
          loggedInUser: widget.loggedInUser,
          cartManager: _cartManager,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _cartManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cartLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_cartManager.loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_cartManager.loadError!),
              TextButton(
                onPressed: () {
                  setState(() => _cartLoading = true);
                  _loadCart();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
