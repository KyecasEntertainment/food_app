import 'package:flutter/material.dart';
import 'package:food_app/screen/menu_screen.dart';
import 'package:food_app/screen/search_screen.dart';
import 'package:food_app/screen/cart_screen.dart';
import 'package:food_app/screen/profile_screen.dart';
import 'package:food_app/bottom_nav_bar.dart';
import 'package:food_app/screen/login_screen.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/screen/delivery_screen.dart';


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
      home: const OrderTrackingPage(),
      // routes: {
      //   '/main': (context) => const MainScreen(),
      // },
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(loggedInUser: widget.loggedInUser),
      SearchPage(loggedInUser: widget.loggedInUser),
      CartPage(loggedInUser: widget.loggedInUser),
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







