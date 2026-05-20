import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_type.dart';
import '../../widgets/phone_frame.dart';

class OrganizerBoothFormPage extends StatefulWidget {
  const OrganizerBoothFormPage({
    super.key,
    required this.eventId,
    this.boothType,
  });

  final int eventId;
  final AdminBoothType? boothType;

  @override
  State<OrganizerBoothFormPage> createState() => _OrganizerBoothFormPageState();
}

class _OrganizerBoothFormPageState extends State<OrganizerBoothFormPage> {
  final db = AdminDatabase.instance;
  final priceController = TextEditingController();
  List<AdminBoothType> eventTypes = [];
  AdminBoothType? selectedType;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    // Only show types the admin has already created for this specific event
    final types = await db.fetchBoothTypesForEvent(widget.eventId);
    if (!mounted) return;

    AdminBoothType? initial;
    if (widget.boothType != null) {
      try {
        initial = types.firstWhere((t) => t.id == widget.boothType!.id);
      } catch (_) {
        initial = types.isNotEmpty ? types.first : null;
      }
    } else {
      initial = types.isNotEmpty ? types.first : null;
    }

    setState(() {
      eventTypes = types;
      selectedType = initial;
      if (initial != null && priceController.text.isEmpty) {
        priceController.text = initial.price > 0
            ? initial.price.toStringAsFixed(0)
            : '';
      }
    });
  }

  void _onTypeChanged(AdminBoothType? type) {
    if (type == null) return;
    setState(() {
      selectedType = type;
      priceController.text =
          type.price > 0 ? type.price.toStringAsFixed(0) : '';
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final type = selectedType;
    if (type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booth type.')),
      );
      return;
    }
    final price = double.tryParse(priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price.')),
      );
      return;
    }
    // Update the existing booth type's price (uses type.id → UPDATE, not INSERT)
    await db.upsertBoothType(
      AdminBoothType(
        id: type.id,
        eventId: widget.eventId,
        name: type.name,
        price: price,
        available: type.available,
        count: type.count,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final hasTypes = eventTypes.isNotEmpty;

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
                  const Text(
                    'Set Booth Price',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Booth Type'),
                  const SizedBox(height: 6),
                  if (!hasTypes)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No booth types available for this event. '
                        'Admin must create booth types first.',
                        style: TextStyle(color: Colors.black45),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AdminBoothType>(
                          value: selectedType,
                          isExpanded: true,
                          items: eventTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name),
                                ),
                              )
                              .toList(),
                          onChanged: _onTypeChanged,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text('Booth Price (RM)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    enabled: hasTypes,
                    decoration: InputDecoration(
                      hintText: 'E.g 500',
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
                          onPressed: hasTypes ? _submit : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text('Save'),
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
