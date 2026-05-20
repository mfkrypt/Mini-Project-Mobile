import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_type.dart';
import '../../models/admin_event.dart';
import '../../widgets/phone_frame.dart';

class OrganizerBoothsPage extends StatefulWidget {
  const OrganizerBoothsPage({super.key, required this.organizerId});

  final int organizerId;

  @override
  State<OrganizerBoothsPage> createState() => _OrganizerBoothsPageState();
}

class _OrganizerBoothsPageState extends State<OrganizerBoothsPage> {
  final db = AdminDatabase.instance;
  List<AdminEvent> events = [];
  List<AdminBoothType> boothTypes = [];
  int? selectedEventId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedEvents = await db.fetchOrganizerEvents(widget.organizerId);
    final hasSelectedEvent = loadedEvents.any(
      (event) => event.id == selectedEventId,
    );
    final eventId = hasSelectedEvent
        ? selectedEventId
        : (loadedEvents.isNotEmpty ? loadedEvents.first.id : null);
    final types = eventId == null
        ? <AdminBoothType>[]
        : await db.fetchBoothTypesForEvent(eventId);

    if (!mounted) {
      return;
    }

    setState(() {
      events = loadedEvents;
      selectedEventId = eventId;
      boothTypes = types;
    });
  }

  Future<void> _showBoothDialog({AdminBoothType? boothType}) async {
    if (selectedEventId == null) {
      return;
    }
    final nameController = TextEditingController(text: boothType?.name ?? '');
    final priceController = TextEditingController(
      text: boothType?.price.toString() ?? '',
    );
    final countController = TextEditingController(
      text: boothType?.count.toString() ?? '',
    );
    bool available = boothType?.available ?? true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(boothType == null ? 'New Booth' : 'Edit Booth'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Booth Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Booth Price (RM)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: countController,
                decoration: const InputDecoration(labelText: 'Count'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  const Text('Available'),
                  const Spacer(),
                  Switch(
                    value: available,
                    onChanged: (value) => available = value,
                  ),
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
      await db.upsertBoothType(
        AdminBoothType(
          id: boothType?.id,
          eventId: selectedEventId!,
          name: nameController.text.trim(),
          price: double.tryParse(priceController.text.trim()) ?? 0,
          available: available,
          count: int.tryParse(countController.text.trim()) ?? 0,
        ),
      );
      await _loadData();
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
          const SizedBox(height: 12),
          if (events.isNotEmpty)
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedEventId,
                items: events
                    .map(
                      (event) => DropdownMenuItem(
                        value: event.id,
                        child: Text(event.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedEventId = value);
                    _loadData();
                  }
                },
              ),
            ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => _showBoothDialog(),
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffd9d9d9), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 6),
                  Text('Create Booth'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (boothTypes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: Text('No booth types yet.')),
            ),
          for (final booth in boothTypes)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xfff1ecec),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      booth.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text('RM ${booth.price.toStringAsFixed(0)}'),
                  const SizedBox(width: 12),
                  Switch(
                    value: booth.available,
                    onChanged: (value) async {
                      await db.upsertBoothType(
                        AdminBoothType(
                          id: booth.id,
                          eventId: booth.eventId,
                          name: booth.name,
                          price: booth.price,
                          available: value,
                          count: booth.count,
                        ),
                      );
                      await _loadData();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
