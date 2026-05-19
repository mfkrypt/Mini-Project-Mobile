import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../models/booth.dart';
import '../cart_page.dart';
import '../../floor_plan_page.dart';
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

  void _clearCart() {
    cart.clear();
    setState(() {});
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
              ),
            ),
          );
        },
      ),
      CartPage(
        cart: cart,
        exhibitorId: widget.user.id ?? 0,
        onSubmitted: _clearCart,
      ),
      MyApplicationsPage(exhibitorId: widget.user.id ?? 0),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Colors.black,
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
        ],
      ),
    );
  }
}
