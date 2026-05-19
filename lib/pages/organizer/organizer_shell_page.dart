import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import 'organizer_booths_page.dart';
import 'organizer_exhibitions_page.dart';
import 'organizer_requests_page.dart';

class OrganizerShellPage extends StatefulWidget {
  const OrganizerShellPage({super.key, required this.user});

  final AdminUser user;

  @override
  State<OrganizerShellPage> createState() => _OrganizerShellPageState();
}

class _OrganizerShellPageState extends State<OrganizerShellPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OrganizerRequestsPage(organizerId: widget.user.id ?? 0),
      OrganizerExhibitionsPage(organizerId: widget.user.id ?? 0),
      OrganizerBoothsPage(organizerId: widget.user.id ?? 0),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Exhibitions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Booths',
          ),
        ],
      ),
    );
  }
}
