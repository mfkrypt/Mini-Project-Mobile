import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_event.dart';
import '../../widgets/phone_frame.dart';

class OrganizerExhibitionFormPage extends StatefulWidget {
  const OrganizerExhibitionFormPage({
    super.key,
    required this.organizerId,
    this.event,
  });

  final int organizerId;
  final AdminEvent? event;

  @override
  State<OrganizerExhibitionFormPage> createState() =>
      _OrganizerExhibitionFormPageState();
}

class _OrganizerExhibitionFormPageState
    extends State<OrganizerExhibitionFormPage> {
  final db = AdminDatabase.instance;
  final nameController = TextEditingController();
  final venueController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    if (event != null) {
      nameController.text = event.name;
      venueController.text = event.venue;
      startDate = DateTime.tryParse(event.startDate);
      endDate = DateTime.tryParse(event.endDate);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    venueController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = (isStart ? startDate : endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final venue = venueController.text.trim();
    if (name.isEmpty || startDate == null || endDate == null || venue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    await db.upsertEvent(
      AdminEvent(
        id: widget.event?.id,
        name: name,
        venue: venue,
        startDate: startDate!.toIso8601String().split('T').first,
        endDate: endDate!.toIso8601String().split('T').first,
        isPublished: widget.event?.isPublished ?? true,
        organizerId: widget.organizerId,
        blockAdjacent: widget.event?.blockAdjacent ?? true,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;
    return Scaffold(
      body: PhoneFrame(
        child: ListView(
          children: [
            Container(
              color: const Color(0xffd9d9d9),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: const Text(
                'Organizer Page',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Exhibition' : 'New Exhibition',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Exhibition Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'E.g',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Starting Date'),
                            const SizedBox(height: 6),
                            _DateField(
                              date: startDate,
                              hint: '4/18/2026',
                              onTap: () => _pickDate(true),
                              formatDate: _formatDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ending Date'),
                            const SizedBox(height: 6),
                            _DateField(
                              date: endDate,
                              hint: '4/25/2026',
                              onTap: () => _pickDate(false),
                              formatDate: _formatDate,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Location'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: venueController,
                    decoration: InputDecoration(
                      hintText: 'E.g',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text(isEdit ? 'Save' : 'Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.hint,
    required this.onTap,
    required this.formatDate,
  });

  final DateTime? date;
  final String hint;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date == null ? hint : formatDate(date!),
                style: TextStyle(
                  color: date == null ? Colors.black38 : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
