import 'package:flutter/material.dart';

import '../data/admin_database.dart';
import '../models/admin_event.dart';
import '../models/exhibition_event.dart';
import '../widgets/divider_line.dart';
import '../widgets/event_card.dart';
import '../widgets/list_header.dart';
import '../widgets/phone_frame.dart';
import '../widgets/search_box.dart';
import 'event_detail_page.dart';

class ExhibitionListPage extends StatefulWidget {
  const ExhibitionListPage({super.key});

  @override
  State<ExhibitionListPage> createState() => _ExhibitionListPageState();
}

class _ExhibitionListPageState extends State<ExhibitionListPage> {
  String searchText = '';
  final db = AdminDatabase.instance;

  Color _statusColor(String status) {
    switch (status) {
      case 'Ongoing':
        return const Color(0xff55bd69);
      case 'Upcoming':
        return const Color(0xff4389f4);
      default:
        return const Color(0xff909090);
    }
  }

  String _statusFromDates(String startDate, String endDate) {
    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);
    if (start == null || end == null) {
      return 'Upcoming';
    }
    final now = DateTime.now();
    if (now.isAfter(end)) {
      return 'Completed';
    }
    if (now.isBefore(start)) {
      return 'Upcoming';
    }
    return 'Ongoing';
  }

  ExhibitionEvent _toUiEvent(AdminEvent event) {
    final status = _statusFromDates(event.startDate, event.endDate);
    return ExhibitionEvent(
      id: event.id ?? 0,
      title: event.name,
      startDate: event.startDate,
      endDate: event.endDate,
      venue: event.venue,
      status: status,
      statusColor: _statusColor(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchText.toLowerCase();

    return Scaffold(
      body: PhoneFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 52, child: _StatusBarSpace()),
            const DividerLine(),
            const ListHeader(),
            const DividerLine(),

            Expanded(
              child: FutureBuilder<List<AdminEvent>>(
                future: db.fetchPublishedEvents(),
                builder: (context, snapshot) {
                  final events = snapshot.data ?? [];
                  final visibleEvents = events
                      .map(_toUiEvent)
                      .where((event) {
                        final target =
                            '${event.title} ${event.startDate} ${event.endDate} ${event.venue} ${event.status}'
                                .toLowerCase();
                        return target.contains(query);
                      })
                      .toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      const Text(
                        'Exhibition Events:',
                        style: TextStyle(fontSize: 21, color: Colors.black),
                      ),
                      const SizedBox(height: 6),
                      SearchBox(
                        onChanged: (value) =>
                            setState(() => searchText = value),
                      ),
                      const SizedBox(height: 20),
                      if (visibleEvents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('No events found.')),
                        ),
                      for (final event in visibleEvents) ...[
                        EventCard(
                          event: event,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EventDetailPage(event: event),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBarSpace extends StatelessWidget {
  const _StatusBarSpace();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(31, 12, 31, 0),
    );
  }
}