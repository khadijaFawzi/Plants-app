import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'manage_screen.dart';
import 'cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _current = 0;
  final _pages = const [HomeScreen(), ManageScreen(), CartScreen()];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _current == 0 ? 'Plant Store'
            : _current == 1 ? 'Manage Products' : 'Your Cart'
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') {
                context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'profile',
                child: Row(children: [ const Icon(Icons.person, color: Colors.grey), const SizedBox(width: 8), Text('Hi, $name') ])
              ),
              const PopupMenuItem(value: 'logout',
                child: Row(children: [ Icon(Icons.logout, color: Colors.grey), SizedBox(width: 8), Text('Logout') ])
              ),
            ],
          ),
        ],
      ),
      body: _pages[_current],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
        ]),
        child: BottomNavigationBar(
          currentIndex: _current,
          onTap: (i) => setState(() => _current = i),
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), activeIcon: Icon(Icons.edit), label: 'Manage'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          ],
        ),
      ),
    );
  }
}
