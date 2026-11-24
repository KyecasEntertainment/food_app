import 'package:flutter/material.dart';
import 'package:food_app/screen/menu_screen.dart';
import 'package:food_app/screen/search_screen.dart';
import 'package:food_app/screen/cart_screen.dart';
import 'package:food_app/screen/profile_screen.dart';
import 'package:food_app/bottom_nav_bar.dart';
import 'package:food_app/screen/login_screen.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
      home: const LoginScreen(),
    );
  }
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
  late final CartManager _cartManager = CartManager(
    accountId: widget.loggedInUser?.id,
  );

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _cartManager.load();
    _buildPages();
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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
