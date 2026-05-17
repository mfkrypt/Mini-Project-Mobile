import 'package:flutter/material.dart';

import '../data/exhibition_data.dart';
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

  @override
  Widget build(BuildContext context) {
    final query = searchText.toLowerCase();

    final visibleEvents = exhibitionEvents.where((event) {
      return event.title.toLowerCase().contains(query) ||
          event.date.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query) ||
          event.status.toLowerCase().contains(query);
    }).toList();

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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const Text(
                    'Exhibition Events:',
                    style: TextStyle(fontSize: 21, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  SearchBox(
                    onChanged: (value) => setState(() => searchText = value),
                  ),
                  const SizedBox(height: 20),
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