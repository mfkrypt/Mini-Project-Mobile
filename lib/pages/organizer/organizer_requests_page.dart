import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_event.dart';
import '../../models/exhibitor_application.dart';
import '../../widgets/phone_frame.dart';

class OrganizerRequestsPage extends StatefulWidget {
  const OrganizerRequestsPage({super.key, required this.organizerId});

  final int organizerId;

  @override
  State<OrganizerRequestsPage> createState() => _OrganizerRequestsPageState();
}

class _OrganizerRequestsPageState extends State<OrganizerRequestsPage> {
  final db = AdminDatabase.instance;
  String status = 'Pending';
  Future<List<ExhibitorApplication>> applicationsFuture = Future.value([]);
  List<AdminEvent> events = [];
  int? selectedEventId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _reload() {
    applicationsFuture = db.fetchOrganizerApplications(
      widget.organizerId,
      status,
      eventId: selectedEventId,
    );
  }

  Future<void> _loadData() async {
    final loadedEvents = await db.fetchOrganizerEvents(widget.organizerId);
    final hasSelectedEvent = loadedEvents.any(
      (event) => event.id == selectedEventId,
    );
    final eventId = hasSelectedEvent
        ? selectedEventId
        : (loadedEvents.isNotEmpty ? loadedEvents.first.id : null);

    if (!mounted) {
      return;
    }

    setState(() {
      events = loadedEvents;
      selectedEventId = eventId;
      _reload();
    });
  }

  Future<void> _updateStatus(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xfff0f0f0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: DropdownButtonHideUnderline(
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
                      setState(() {
                        selectedEventId = value;
                        _reload();
                      });
                    }
                  },
                ),
              ),
            ),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Create an exhibition before reviewing requests.'),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xfff0f0f0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                      _reload();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<ExhibitorApplication>>(
            future: applicationsFuture,
            builder: (context, snapshot) {
              final applications = snapshot.data ?? [];
              if (applications.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: Text('No applications found.')),
                );
              }
              return Column(
                children: applications
                    .map(
                      (application) => _RequestCard(
                        application: application,
                        status: status,
                        onApprove: () => _updateStatus(application, 'Approved'),
                        onReject: () => _updateStatus(application, 'Rejected'),
                        onCancel: () => _updateStatus(application, 'Cancelled'),
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.application,
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.onCancel,
  });

  final ExhibitorApplication application;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff1ecec),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.boothLabel ?? 'Booth',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(application.companyName),
                if (application.eventName != null) Text(application.eventName!),
                const SizedBox(height: 6),
                Text('Total RM ${application.totalPrice.toStringAsFixed(0)}'),
              ],
            ),
          ),
          if (status == 'Pending')
            Column(
              children: [
                OutlinedButton(
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
              ],
            ),
          if (status == 'Approved')
            OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
        ],
      ),
    );
  }
}
