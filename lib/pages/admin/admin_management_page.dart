import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_type.dart';
import '../../models/admin_event.dart';
import '../../models/admin_reservation.dart';
import '../../widgets/admin_table.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  final db = AdminDatabase.instance;
  late Future<List<AdminReservation>> reservationsFuture;
  late Future<List<AdminEvent>> eventsFuture;
  late Future<List<AdminBoothType>> boothTypesFuture;
  String reservationQuery = '';
  String eventQuery = '';
  String boothQuery = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    reservationsFuture = db.fetchReservations();
    eventsFuture = db.fetchEvents();
    boothTypesFuture = db.fetchBoothTypes();
  }

  Future<void> _showReservationDialog({AdminReservation? reservation}) async {
    final dateController = TextEditingController(text: reservation?.date ?? '');
    final emailController = TextEditingController(text: reservation?.email ?? '');

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(reservation == null ? 'Add Reservation' : 'Edit Reservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
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

    if (shouldSave == true) {
      await db.upsertReservation(
        AdminReservation(
          id: reservation?.id,
          date: dateController.text.trim(),
          email: emailController.text.trim(),
          status: reservation?.status ?? 'Active',
        ),
      );
      setState(_reload);
    }
  }

  Future<void> _deleteReservation(AdminReservation reservation) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Reservation'),
          content: Text('Cancel booking for ${reservation.email}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && reservation.id != null) {
      await db.deleteReservation(reservation.id!);
      setState(_reload);
    }
  }

  Future<void> _showEventDialog({AdminEvent? event}) async {
    final nameController = TextEditingController(text: event?.name ?? '');
    final dateController = TextEditingController(text: event?.date ?? '');
    bool published = event?.isPublished ?? true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              Row(
                children: [
                  const Text('Published'),
                  const Spacer(),
                  Switch(
                    value: published,
                    onChanged: (value) => published = value,
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

    if (shouldSave == true) {
      await db.upsertEvent(
        AdminEvent(
          id: event?.id,
          name: nameController.text.trim(),
          date: dateController.text.trim(),
          isPublished: published,
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
    final nameController = TextEditingController(text: boothType?.name ?? '');
    final priceController =
        TextEditingController(text: boothType?.price.toString() ?? '');
    final countController =
        TextEditingController(text: boothType?.count.toString() ?? '');
    bool available = boothType?.available ?? true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(boothType == null ? 'Add Booth Type' : 'Edit Booth Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      await db.upsertBoothType(
        AdminBoothType(
          id: boothType?.id,
          name: nameController.text.trim(),
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
            onChanged: (value) => setState(() => reservationQuery = value),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Filter by date or email',
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<AdminReservation>>(
          future: reservationsFuture,
          builder: (context, snapshot) {
            final reservations = snapshot.data ?? [];
            final filtered = reservations.where((reservation) {
              final target =
                  '${reservation.date} ${reservation.email}'.toLowerCase();
              return target.contains(reservationQuery.toLowerCase());
            }).toList();
            return AdminTable(
              headers: const ['ID', 'Date', 'Email', 'Actions'],
              columnWidths: const {
                0: FixedColumnWidth(34),
                1: FixedColumnWidth(80),
                2: FlexColumnWidth(),
                3: FixedColumnWidth(80),
              },
              rows: filtered
                  .map(
                    (reservation) => [
                      Text('${reservation.id ?? ''}'),
                      Text(reservation.date),
                      Text(reservation.email, overflow: TextOverflow.ellipsis),
                      Row(
                        children: [
                          AdminActionIcon(
                            icon: Icons.remove_red_eye_outlined,
                            onPressed: () => _showReservationDialog(
                              reservation: reservation,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AdminActionIcon(
                            icon: Icons.edit,
                            onPressed: () => _showReservationDialog(
                              reservation: reservation,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AdminActionIcon(
                            icon: Icons.close,
                            onPressed: () => _deleteReservation(reservation),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              final target = '${event.name} ${event.date}'.toLowerCase();
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
                      Text(event.date),
                      Switch(
                        value: event.isPublished,
                        onChanged: (value) async {
                          await db.upsertEvent(
                            AdminEvent(
                              id: event.id,
                              name: event.name,
                              date: event.date,
                              isPublished: value,
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
        FutureBuilder<List<AdminBoothType>>(
          future: boothTypesFuture,
          builder: (context, snapshot) {
            final boothTypes = snapshot.data ?? [];
            final filtered = boothTypes.where((type) {
              final target =
                  '${type.name} ${type.price} ${type.count}'.toLowerCase();
              return target.contains(boothQuery.toLowerCase());
            }).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminTable(
                  headers: const ['Booth Type', 'Price', 'Availability', 'Count'],
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(90),
                    3: FixedColumnWidth(60),
                  },
                  rows: filtered
                      .map(
                        (type) => [
                          Text(type.name),
                          Text('RM ${type.price.toStringAsFixed(0)}'),
                          Switch(
                            value: type.available,
                            onChanged: (value) async {
                              await db.upsertBoothType(
                                AdminBoothType(
                                  id: type.id,
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
                        ],
                      )
                      .toList(),
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
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: boothTypes.isEmpty
                        ? null
                        : () => _showBoothDialog(boothType: boothTypes.last),
                    child: const Text('Edit Last Booth'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
