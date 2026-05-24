import 'package:flutter/material.dart';

import 'data/admin_database.dart';
import 'floor_plan_page.dart';
import 'models/admin_event.dart';
import 'models/booth.dart';
import 'models/exhibition_event.dart';

class EventSelectionPage extends StatelessWidget {
  EventSelectionPage({super.key});

  final db = AdminDatabase.instance;

  ExhibitionEvent _toUi(AdminEvent event) {
    return ExhibitionEvent(
      id: event.id ?? 0,
      title: event.name,
      startDate: event.startDate,
      endDate: event.endDate,
      venue: event.venue,
      status: 'Upcoming',
      statusColor: const Color(0xff4389f4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Event')),
      body: FutureBuilder<List<AdminEvent>>(
        future: db.fetchPublishedEvents(),
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = _toUi(events[index]);
              return ListTile(
                title: Text(event.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FloorPlanPage(
                        event: event,
                        exhibitorId: 0,
                        cart: <Booth>[],
                        onSubmitted: () {},
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
