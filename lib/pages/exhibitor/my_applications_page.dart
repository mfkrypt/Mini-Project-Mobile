import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/exhibitor_application.dart';
import '../../widgets/phone_frame.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key, required this.exhibitorId});

  final int exhibitorId;

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  final db = AdminDatabase.instance;
  late Future<List<ExhibitorApplication>> applicationsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    applicationsFuture = db.fetchApplicationsForExhibitor(widget.exhibitorId);
  }

  Future<void> _showEditDialog(ExhibitorApplication application) async {
    final companyController =
        TextEditingController(text: application.companyName);
    final companyDescController =
        TextEditingController(text: application.companyDescription);
    final exhibitController =
        TextEditingController(text: application.exhibitDescription);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Application'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              TextField(
                controller: companyDescController,
                decoration: const InputDecoration(labelText: 'Company Details'),
              ),
              TextField(
                controller: exhibitController,
                decoration: const InputDecoration(labelText: 'Exhibit Profile'),
                maxLines: 2,
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
      await db.updateApplication(
        ExhibitorApplication(
          id: application.id,
          eventId: application.eventId,
          exhibitorId: application.exhibitorId,
          companyName: companyController.text.trim(),
          companyDescription: companyDescController.text.trim(),
          exhibitDescription: exhibitController.text.trim(),
          eventStartDate: application.eventStartDate,
          eventEndDate: application.eventEndDate,
          status: application.status,
          submittedAt: application.submittedAt,
          totalPrice: application.totalPrice,
          decisionReason: application.decisionReason,
        ),
      );
      setState(_reload);
    }
  }

  Future<void> _cancelApplication(ExhibitorApplication application) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Application'),
          content: Text('Cancel ${application.eventName ?? 'this event'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancel Application'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true && application.id != null) {
      await db.updateApplicationStatus(
        application.id!,
        'Cancelled',
        'Cancelled by exhibitor',
      );
      final boothIds = await db.fetchApplicationBoothIds(application.id!);
      for (final boothId in boothIds) {
        await db.updateBoothStatus(boothId, 'available');
      }
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          const Text(
            'My Applications',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ExhibitorApplication>>(
            future: applicationsFuture,
            builder: (context, snapshot) {
              final applications = snapshot.data ?? [];
              if (applications.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No applications yet.')),
                );
              }
              return Column(
                children: applications
                    .map((application) => _ApplicationCard(
                          application: application,
                          onEdit: application.status == 'Pending'
                              ? () => _showEditDialog(application)
                              : null,
                          onCancel: application.status == 'Pending'
                              ? () => _cancelApplication(application)
                              : null,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.onEdit,
    required this.onCancel,
  });

  final ExhibitorApplication application;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xff55bd69);
      case 'Rejected':
      case 'Cancelled':
        return const Color(0xffd9534f);
      default:
        return const Color(0xff909090);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffefefef),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  application.eventName ?? 'Event',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(application.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application.status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Booth: ${application.boothLabel ?? '-'}'),
          Text('Company: ${application.companyName}'),
          Text('Total: RM ${application.totalPrice.toStringAsFixed(0)}'),
          if (application.decisionReason != null &&
              application.decisionReason!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Reason: ${application.decisionReason}'),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onEdit != null)
                OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              if (onCancel != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
