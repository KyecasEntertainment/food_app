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

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bottom Navigation App',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.orange,
          tertiary: AppColors.lavender,
          surface: AppColors.surface,
          onPrimary: AppColors.text,
          onSecondary: AppColors.ink,
          onSurface: AppColors.text,
          error: AppColors.orange,
          onError: AppColors.ink,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.text,
        ),
        cardColor: AppColors.surface,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: AppColors.text),
          hintStyle: TextStyle(color: AppColors.text),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: AppColors.text),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {'/main': (context) => const MainScreen()},
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
  final CartManager _cartManager = CartManager();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      HomePage(loggedInUser: widget.loggedInUser, cartManager: _cartManager),
      SearchPage(loggedInUser: widget.loggedInUser, cartManager: _cartManager),
      CartPage(loggedInUser: widget.loggedInUser, cartManager: _cartManager),
      ProfilePage(loggedInUser: widget.loggedInUser),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
