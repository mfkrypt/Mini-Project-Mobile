import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_event.dart';
import '../../widgets/phone_frame.dart';

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

  Future<void> _showEventDialog({AdminEvent? event}) async {
    final nameController = TextEditingController(text: event?.name ?? '');
    final startController =
        TextEditingController(text: event?.startDate ?? '');
    final endController = TextEditingController(text: event?.endDate ?? '');
    final venueController = TextEditingController(text: event?.venue ?? '');
    bool published = event?.isPublished ?? true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event == null ? 'New Exhibition' : 'Edit Exhibition'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exhibition Name'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration:
                          const InputDecoration(labelText: 'Starting Date'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration:
                          const InputDecoration(labelText: 'Ending Date'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: venueController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              Row(
                children: [
                  const Text('Published'),
                  const Spacer(),
                  Switch(value: published, onChanged: (value) => published = value),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      await db.upsertEvent(
        AdminEvent(
          id: event?.id,
          name: nameController.text.trim(),
          venue: venueController.text.trim(),
          startDate: startController.text.trim(),
          endDate: endController.text.trim(),
          isPublished: published,
          organizerId: widget.organizerId,
          blockAdjacent: event?.blockAdjacent ?? true,
        ),
      );
      setState(_reload);
    }
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
            onTap: () => _showEventDialog(),
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
              final events = snapshot.data ?? [];
              return Column(
                children: events
                    .map(
                      (event) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfff1ecec),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => _showEventDialog(event: event),
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
                                    Text('${event.startDate} - ${event.endDate}'),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit, size: 18),
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
