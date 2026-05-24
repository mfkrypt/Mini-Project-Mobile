import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../models/booth.dart';
import '../../floor_plan_page.dart';
import '../cart_page.dart';
import '../exhibition_list_page.dart';
import 'exhibitor_home_page.dart';
import 'my_applications_page.dart';

class ExhibitorShellPage extends StatefulWidget {
  const ExhibitorShellPage({super.key, required this.user});

  final AdminUser user;

  @override
  State<ExhibitorShellPage> createState() => _ExhibitorShellPageState();
}

class _ExhibitorShellPageState extends State<ExhibitorShellPage> {
  int currentIndex = 0;
  final List<Booth> cart = [];

  void _handleApplicationSubmitted() {
    cart.clear();
    setState(() => currentIndex = 0);
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ExhibitionListPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ExhibitorHomePage(
        user: widget.user,
        onOpenEvent: (event) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FloorPlanPage(
                event: event,
                exhibitorId: widget.user.id ?? 0,
                cart: cart,
                onSubmitted: _handleApplicationSubmitted,
              ),
            ),
          );
        },
      ),
      CartPage(
        cart: cart,
        exhibitorId: widget.user.id ?? 0,
        onSubmitted: _handleApplicationSubmitted,
      ),
      MyApplicationsPage(exhibitorId: widget.user.id ?? 0),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == pages.length) {
            _logout();
            return;
          }
          setState(() => currentIndex = index);
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Applications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
