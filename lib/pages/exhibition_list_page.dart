import 'package:flutter/material.dart';

import '../data/admin_database.dart';
import '../models/admin_event.dart';
import '../models/exhibition_event.dart';
import '../utils/app_route_observer.dart';
import '../utils/event_dates.dart';
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

class _ExhibitionListPageState extends State<ExhibitionListPage>
    with RouteAware {
  String searchText = '';
  final db = AdminDatabase.instance;
  late Future<List<AdminEvent>> eventsFuture;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshEvents();
  }

  void _loadEvents() {
    eventsFuture = db.fetchPublishedEvents();
  }

  Future<void> _refreshEvents() async {
    setState(_loadEvents);
    await eventsFuture;
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

  ExhibitionEvent _toUiEvent(AdminEvent event) {
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
                future: eventsFuture,
                builder: (context, snapshot) {
                  final events = snapshot.data ?? [];
                  final visibleEvents = events.map(_toUiEvent).where((event) {
                    final target =
                        '${event.title} ${event.startDate} ${event.endDate} ${event.venue} ${event.status}'
                            .toLowerCase();
                    return target.contains(query);
                  }).toList();
                  return RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: ListView(
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
                        if (snapshot.connectionState != ConnectionState.done)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (snapshot.hasError)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'Could not load events.\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                        else if (visibleEvents.isEmpty)
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
                    ),
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
    return const Padding(padding: EdgeInsets.fromLTRB(31, 12, 31, 0));
  }
}
