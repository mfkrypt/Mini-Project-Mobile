import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_type.dart';
import '../../models/admin_event.dart';
import '../../models/exhibitor_application.dart';
import '../../utils/event_dates.dart';
import '../../widgets/admin_table.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  final db = AdminDatabase.instance;
  late Future<List<ExhibitorApplication>> applicationsFuture;
  late Future<List<AdminEvent>> eventsFuture;
  late Future<List<AdminBoothType>> boothTypesFuture;
  String applicationQuery = '';
  String applicationStatus = 'Pending';
  String eventQuery = '';
  String boothQuery = '';
  int? selectedApplicationEventId;
  int? selectedBoothEventId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    eventsFuture = db.fetchEvents();
    applicationsFuture = db.fetchAllApplications(
      applicationStatus,
      eventId: selectedApplicationEventId,
    );
    boothTypesFuture = selectedBoothEventId == null
        ? db.fetchBoothTypes()
        : db.fetchBoothTypesForEvent(selectedBoothEventId!);
  }

  String _eventNameById(List<AdminEvent> events, int eventId) {
    for (final event in events) {
      if (event.id == eventId) {
        return event.name;
      }
    }
    return 'Event #$eventId';
  }

  Future<void> _updateApplicationStatus(
    ExhibitorApplication application,
    String nextStatus,
  ) async {
    final reasonController = TextEditingController();
    final needsReason = nextStatus == 'Rejected' || nextStatus == 'Cancelled';
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reason for ${nextStatus.toLowerCase()}'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Reason'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      final reason = reasonController.text.trim();
      final finalReason = needsReason && reason.isEmpty
          ? 'No reason provided'
          : reason;
      await db.updateApplicationStatus(
        application.id!,
        nextStatus,
        needsReason ? finalReason : null,
      );
      if (nextStatus == 'Approved' ||
          nextStatus == 'Rejected' ||
          nextStatus == 'Cancelled') {
        final boothIds = await db.fetchApplicationBoothIds(application.id!);
        for (final boothId in boothIds) {
          await db.updateBoothStatus(
            boothId,
            nextStatus == 'Approved' ? 'booked' : 'available',
          );
        }
      }
      if (!mounted) {
        return;
      }
      setState(_reload);
    }
  }

  Future<void> _showEventDialog({AdminEvent? event}) async {
    final nameController = TextEditingController(text: event?.name ?? '');
    final startController = TextEditingController(
      text: event == null ? '' : formatEventDateForDisplay(event.startDate),
    );
    final endController = TextEditingController(
      text: event == null ? '' : formatEventDateForDisplay(event.endDate),
    );
    final venueController = TextEditingController(text: event?.venue ?? '');
    final organizerController = TextEditingController(
      text: '${event?.organizerId ?? 0}',
    );
    bool published = event?.isPublished ?? true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(event == null ? 'Add Event' : 'Edit Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Event Name'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startController,
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            hintText: 'DDMMYY',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [EventDateInputFormatter()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: endController,
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            hintText: 'DDMMYY',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [EventDateInputFormatter()],
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: venueController,
                    decoration: const InputDecoration(labelText: 'Venue'),
                  ),
                  TextField(
                    controller: organizerController,
                    decoration: const InputDecoration(
                      labelText: 'Organizer ID',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      const Text('Published'),
                      const Spacer(),
                      Switch(
                        value: published,
                        onChanged: (value) {
                          setDialogState(() => published = value);
                        },
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave == true) {
      await db.upsertEvent(
        AdminEvent(
          id: event?.id,
          name: nameController.text.trim(),
          venue: venueController.text.trim(),
          startDate: normalizeEventDateInput(startController.text),
          endDate: normalizeEventDateInput(endController.text),
          isPublished: published,
          organizerId: int.tryParse(organizerController.text.trim()) ?? 0,
          blockAdjacent: event?.blockAdjacent ?? true,
        ),
      );
      setState(_reload);
    }
  }

  Future<void> _deleteEvent(AdminEvent event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Delete ${event.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && event.id != null) {
      await db.deleteEvent(event.id!);
      setState(_reload);
    }
  }

  Future<void> _showBoothDialog({AdminBoothType? boothType}) async {
    final events = await db.fetchEvents();
    if (!mounted) {
      return;
    }
    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create an event before adding booths.')),
      );
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
    int selectedEventId =
        boothType?.eventId ??
        selectedBoothEventId ??
        (events.isNotEmpty ? events.first.id ?? 0 : 0);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                boothType == null ? 'Add Booth Type' : 'Edit Booth Type',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedEventId,
                      isExpanded: true,
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
                          setDialogState(() => selectedEventId = value);
                        }
                      },
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Booth Type'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
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
                        onChanged: (value) {
                          setDialogState(() => available = value);
                        },
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave == true) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booth type name is required.')),
        );
        return;
      }
      await db.upsertBoothType(
        AdminBoothType(
          id: boothType?.id,
          eventId: selectedEventId,
          name: name,
          price: double.tryParse(priceController.text.trim()) ?? 0,
          available: available,
          count: int.tryParse(countController.text.trim()) ?? 0,
        ),
      );
      setState(_reload);
    }
  }

  Future<void> _deleteBoothType(AdminBoothType boothType) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Booth Type'),
          content: Text('Delete ${boothType.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && boothType.id != null) {
      await db.deleteBoothType(boothType.id!);
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
      children: [
        const Text(
          'Exhibitor Reservations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffd9d9d9),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            onChanged: (value) => setState(() => applicationQuery = value),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Filter by booth, event, or status',
            ),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: applicationStatus,
            items: const [
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Approved', child: Text('Approved')),
              DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  applicationStatus = value;
                  _reload();
                });
              }
            },
          ),
        ),
        FutureBuilder<List<AdminEvent>>(
          future: eventsFuture,
          builder: (context, snapshot) {
            final events = snapshot.data ?? [];
            return DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedApplicationEventId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All events'),
                  ),
                  ...events.map(
                    (event) => DropdownMenuItem<int?>(
                      value: event.id,
                      child: Text(event.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedApplicationEventId = value;
                    _reload();
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<ExhibitorApplication>>(
          future: applicationsFuture,
          builder: (context, snapshot) {
            final applications = snapshot.data ?? [];
            final filtered = applications.where((application) {
              final target =
                  '${application.boothLabel} ${application.eventName} ${application.status}'
                      .toLowerCase();
              return target.contains(applicationQuery.toLowerCase());
            }).toList();
            return AdminTable(
              headers: const ['ID', 'Booth', 'Event', 'Actions'],
              columnWidths: const {
                0: FixedColumnWidth(34),
                1: FixedColumnWidth(70),
                2: FlexColumnWidth(),
                3: FixedColumnWidth(90),
              },
              rows: filtered
                  .map(
                    (application) => [
                      Text('${application.id ?? ''}'),
                      Text(application.boothLabel ?? '-'),
                      Text(
                        application.eventName ?? '-',
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          AdminActionIcon(
                            icon: Icons.check,
                            onPressed: application.id == null
                                ? () {}
                                : () => _updateApplicationStatus(
                                    application,
                                    'Approved',
                                  ),
                          ),
                          const SizedBox(width: 8),
                          AdminActionIcon(
                            icon: Icons.close,
                            onPressed: application.id == null
                                ? () {}
                                : () => _updateApplicationStatus(
                                    application,
                                    applicationStatus == 'Approved'
                                        ? 'Cancelled'
                                        : 'Rejected',
                                  ),
                          ),
                        ],
                      ),
                    ],
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Exhibition Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton(
              onPressed: () => _showEventDialog(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff5d82f6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Add New +'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffd9d9d9),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            onChanged: (value) => setState(() => eventQuery = value),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Filter by event name or date',
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<AdminEvent>>(
          future: eventsFuture,
          builder: (context, snapshot) {
            final events = snapshot.data ?? [];
            final filtered = events.where((event) {
              final target = '${event.name} ${event.startDate} ${event.endDate}'
                  .toLowerCase();
              return target.contains(eventQuery.toLowerCase());
            }).toList();
            return AdminTable(
              headers: const ['Event Name', 'Date', 'Published', 'Actions'],
              columnWidths: const {
                0: FlexColumnWidth(),
                1: FixedColumnWidth(80),
                2: FixedColumnWidth(80),
                3: FixedColumnWidth(70),
              },
              rows: filtered
                  .map(
                    (event) => [
                      Text(event.name),
                      Text(
                        '${formatEventDateForDisplay(event.startDate)} - '
                        '${formatEventDateForDisplay(event.endDate)}',
                      ),
                      Switch(
                        value: event.isPublished,
                        onChanged: (value) async {
                          await db.upsertEvent(
                            AdminEvent(
                              id: event.id,
                              name: event.name,
                              venue: event.venue,
                              startDate: formatEventDateForDisplay(
                                event.startDate,
                              ),
                              endDate: formatEventDateForDisplay(event.endDate),
                              isPublished: value,
                              organizerId: event.organizerId,
                              blockAdjacent: event.blockAdjacent,
                            ),
                          );
                          setState(_reload);
                        },
                      ),
                      Row(
                        children: [
                          AdminActionIcon(
                            icon: Icons.edit,
                            onPressed: () => _showEventDialog(event: event),
                          ),
                          const SizedBox(width: 8),
                          AdminActionIcon(
                            icon: Icons.delete_outline,
                            onPressed: () => _deleteEvent(event),
                          ),
                        ],
                      ),
                    ],
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 26),
        const Text(
          'Booth Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffd9d9d9),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            onChanged: (value) => setState(() => boothQuery = value),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Filter by booth type or price',
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<AdminEvent>>(
          future: eventsFuture,
          builder: (context, snapshot) {
            final events = snapshot.data ?? [];
            return DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedBoothEventId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All events'),
                  ),
                  ...events.map(
                    (event) => DropdownMenuItem<int?>(
                      value: event.id,
                      child: Text(event.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedBoothEventId = value;
                    _reload();
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<AdminBoothType>>(
          future: boothTypesFuture,
          builder: (context, snapshot) {
            final boothTypes = snapshot.data ?? [];
            final filtered = boothTypes.where((type) {
              final target =
                  '${type.name} ${type.price} ${type.count} ${type.eventId}'
                      .toLowerCase();
              return target.contains(boothQuery.toLowerCase());
            }).toList();
            return FutureBuilder<List<AdminEvent>>(
              future: eventsFuture,
              builder: (context, eventSnapshot) {
                final events = eventSnapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 520,
                        child: AdminTable(
                          headers: const [
                            'Event',
                            'Booth Type',
                            'Price',
                            'Availability',
                            'Count',
                            'Actions',
                          ],
                          columnWidths: const {
                            0: FixedColumnWidth(95),
                            1: FixedColumnWidth(95),
                            2: FixedColumnWidth(65),
                            3: FixedColumnWidth(95),
                            4: FixedColumnWidth(60),
                            5: FixedColumnWidth(85),
                          },
                          rows: filtered
                              .map(
                                (type) => [
                                  Text(
                                    _eventNameById(events, type.eventId),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    type.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text('RM ${type.price.toStringAsFixed(0)}'),
                                  Switch(
                                    value: type.available,
                                    onChanged: (value) async {
                                      await db.upsertBoothType(
                                        AdminBoothType(
                                          id: type.id,
                                          eventId: type.eventId,
                                          name: type.name,
                                          price: type.price,
                                          available: value,
                                          count: type.count,
                                        ),
                                      );
                                      setState(_reload);
                                    },
                                  ),
                                  Text('${type.count}'),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AdminActionIcon(
                                        icon: Icons.edit,
                                        onPressed: () =>
                                            _showBoothDialog(boothType: type),
                                      ),
                                      const SizedBox(width: 8),
                                      AdminActionIcon(
                                        icon: Icons.delete_outline,
                                        onPressed: () => _deleteBoothType(type),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => _showBoothDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Booth Type'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xffd9d9d9),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
