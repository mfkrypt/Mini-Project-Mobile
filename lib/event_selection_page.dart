import 'package:flutter/material.dart';
import '../floor_plan_page.dart';

class EventSelectionPage extends StatelessWidget {
  final List<String> events = [
    "Tech Expo 2026",
    "Food Fair 2026",
    "Auto Show 2026"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Event")),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FloorPlanPage()),
              );
            },
          );
        },
      ),
    );
  }
}