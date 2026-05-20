import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_event.dart';
import '../../widgets/phone_frame.dart';
import 'organizer_event_detail_page.dart';
import 'organizer_exhibition_form_page.dart';

class OrganizerExhibitionsPage extends StatefulWidget {
  const OrganizerExhibitionsPage({super.key, required this.organizerId});

  final int organizerId;

  @override
  State<OrganizerExhibitionsPage> createState() =>
      _OrganizerExhibitionsPageState();
}

class _OrganizerExhibitionsPageState extends State<OrganizerExhibitionsPage> {
  final db = AdminDatabase.instance;
  late Future<List<AdminEvent>> eventsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    eventsFuture = db.fetchOrganizerEvents(widget.organizerId);
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            OrganizerExhibitionFormPage(organizerId: widget.organizerId),
      ),
    );
    if (result == true) setState(_reload);
  }

  Future<void> _openEventDetail(AdminEvent event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrganizerEventDetailPage(
          event: event,
          organizerId: widget.organizerId,
        ),
      ),
    );
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        children: [
          const Text(
            'Organizer Page',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          const Text(
            'Exhibitions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _openCreateForm,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xffd9d9d9),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 6),
                  Text('Create Exhibition'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<AdminEvent>>(
            future: eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final events = snapshot.data ?? [];
              if (events.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No exhibitions yet.')),
                );
              }
              return Column(
                children: events
                    .map(
                      (event) => GestureDetector(
                        onTap: () => _openEventDetail(event),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xfff1ecec),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${event.startDate} - ${event.endDate}',
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
