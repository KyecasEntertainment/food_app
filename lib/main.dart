import 'package:flutter/material.dart';
import 'package:food_app/screen/menu_screen.dart';
import 'package:food_app/screen/search_screen.dart';
import 'package:food_app/screen/cart_screen.dart';
import 'package:food_app/screen/profile_screen.dart';
import 'package:food_app/bottom_nav_bar.dart';
import 'package:food_app/screen/login_screen.dart';


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
        colorSchemeSeed: const Color.fromARGB(255, 85, 3, 129),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
      },
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
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const CartPage(),
    const ProfilePage(),
  ];

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







