import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_event.dart';
import '../../models/admin_user.dart';
import '../../models/exhibition_event.dart';
import '../../utils/event_dates.dart';
import '../../widgets/divider_line.dart';
import '../../widgets/event_card.dart';
import '../../widgets/phone_frame.dart';
import '../../widgets/search_box.dart';

class ExhibitorHomePage extends StatefulWidget {
  const ExhibitorHomePage({
    super.key,
    required this.user,
    required this.onOpenEvent,
  });

  final AdminUser user;
  final ValueChanged<ExhibitionEvent> onOpenEvent;

  @override
  State<ExhibitorHomePage> createState() => _ExhibitorHomePageState();
}

class _ExhibitorHomePageState extends State<ExhibitorHomePage> {
  final db = AdminDatabase.instance;
  late final Future<List<AdminEvent>> eventsFuture;
  String query = '';

  @override
  void initState() {
    super.initState();
    eventsFuture = db.fetchPublishedEvents();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Ongoing':
        return const Color(0xff55bd69);
      case 'Upcoming':
        return const Color(0xff4389f4);
      case 'Finished':
        return const Color(0xffd9534f);
      default:
        return const Color(0xff909090);
    }
  }

  ExhibitionEvent _toUi(AdminEvent event) {
    final status = eventStatusFromDates(event.startDate, event.endDate);
    return ExhibitionEvent(
      id: event.id ?? 0,
      title: event.name,
      startDate: formatEventDateForDisplay(event.startDate),
      endDate: formatEventDateForDisplay(event.endDate),
      venue: event.venue,
      status: status,
      statusColor: _statusColor(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xffd9d9d9),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: const Text(
              'Exhibitor Portal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const DividerLine(),
          Expanded(
            child: FutureBuilder<List<AdminEvent>>(
              future: eventsFuture,
              builder: (context, snapshot) {
                final events = snapshot.data ?? [];
                final visible = events.map(_toUi).where((event) {
                  final target =
                      '${event.title} ${event.startDate} ${event.endDate} ${event.venue} ${event.status}'
                          .toLowerCase();
                  return target.contains(query.toLowerCase());
                }).toList();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const Text(
                      'Select an Exhibition',
                      style: TextStyle(fontSize: 21, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    SearchBox(
                      onChanged: (value) => setState(() => query = value),
                    ),
                    const SizedBox(height: 20),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: Text('No events available.')),
                      ),
                    for (final event in visible) ...[
                      EventCard(
                        event: event,
                        onTap: () => widget.onOpenEvent(event),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
