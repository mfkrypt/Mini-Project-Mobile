import 'package:flutter/material.dart';

import '../../widgets/phone_frame.dart';
import 'admin_management_page.dart';
import 'admin_panel_page.dart';
import 'user_management_page.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AdminPanelPage(),
      const UserManagementPage(),
      const AdminManagementPage(),
    ];

    return Scaffold(
      body: PhoneFrame(child: pages[currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Manage',
          ),
        ],
      ),
    );
  }
}
