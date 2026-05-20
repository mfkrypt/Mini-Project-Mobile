import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/exhibitor_application.dart';
import '../../widgets/phone_frame.dart';

class OrganizerRequestsPage extends StatefulWidget {
  const OrganizerRequestsPage({
    super.key,
    required this.organizerId,
    this.eventId,
  });

  final int organizerId;
  final int? eventId;

  @override
  State<OrganizerRequestsPage> createState() => _OrganizerRequestsPageState();
}

class _OrganizerRequestsPageState extends State<OrganizerRequestsPage> {
  final db = AdminDatabase.instance;
  List<ExhibitorApplication> pendingApps = [];
  List<ExhibitorApplication> approvedApps = [];
  Map<int, List<String>> addonsMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final pending = await db.fetchOrganizerApplications(
      widget.organizerId,
      'Pending',
      eventId: widget.eventId,
    );
    final approved = await db.fetchOrganizerApplications(
      widget.organizerId,
      'Approved',
      eventId: widget.eventId,
    );

    final Map<int, List<String>> addons = {};
    for (final app in [...pending, ...approved]) {
      if (app.id != null) {
        addons[app.id!] = await db.fetchApplicationAddonNames(app.id!);
      }
    }

    if (!mounted) return;
    setState(() {
      pendingApps = pending;
      approvedApps = approved;
      addonsMap = addons;
      loading = false;
    });
  }

  Future<void> _updateStatus(
    ExhibitorApplication app,
    String nextStatus,
  ) async {
    final needsReason =
        nextStatus == 'Rejected' || nextStatus == 'Cancelled';
    final reasonController = TextEditingController();

    final title = nextStatus == 'Rejected'
        ? 'Reason Of Rejection'
        : nextStatus == 'Cancelled'
        ? 'Reason Of Cancellation'
        : 'Confirm $nextStatus';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: needsReason
              ? TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter reason here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          actions: [
            if (needsReason)
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Submit'),
              )
            else ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Confirm'),
              ),
            ],
          ],
        );
      },
    );

    if (shouldSave == true) {
      final reason = reasonController.text.trim();
      final finalReason =
          needsReason && reason.isEmpty ? 'No reason provided' : reason;
      await db.updateApplicationStatus(
        app.id!,
        nextStatus,
        needsReason ? finalReason : null,
      );
      final boothIds = await db.fetchApplicationBoothIds(app.id!);
      for (final boothId in boothIds) {
        await db.updateBoothStatus(
          boothId,
          nextStatus == 'Approved' ? 'booked' : 'available',
        );
      }
      if (!mounted) return;
      setState(() => loading = true);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              children: [
                const Text(
                  'Organizer Page',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _AccordionSection(
                  title: 'Pending',
                  initiallyExpanded: true,
                  children: pendingApps.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('No pending applications.'),
                          ),
                        ]
                      : pendingApps
                            .map(
                              (app) => _RequestCard(
                                application: app,
                                addons: addonsMap[app.id] ?? [],
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          _updateStatus(app, 'Approved'),
                                      child: const Text('Approve'),
                                    ),
                                    const SizedBox(height: 6),
                                    OutlinedButton(
                                      onPressed: () =>
                                          _updateStatus(app, 'Rejected'),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                ),
                const SizedBox(height: 8),
                _AccordionSection(
                  title: 'Approved',
                  initiallyExpanded: false,
                  children: approvedApps.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('No approved applications.'),
                          ),
                        ]
                      : approvedApps
                            .map(
                              (app) => _RequestCard(
                                application: app,
                                addons: addonsMap[app.id] ?? [],
                                trailing: OutlinedButton(
                                  onPressed: () =>
                                      _updateStatus(app, 'Cancelled'),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            )
                            .toList(),
                ),
              ],
            ),
    );
  }
}

class _AccordionSection extends StatefulWidget {
  const _AccordionSection({
    required this.title,
    required this.initiallyExpanded,
    required this.children,
  });

  final String title;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  State<_AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<_AccordionSection> {
  late bool expanded;

  @override
  void initState() {
    super.initState();
    expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        if (expanded) ...[
          const SizedBox(height: 8),
          ...widget.children,
        ],
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.application,
    required this.addons,
    required this.trailing,
  });

  final ExhibitorApplication application;
  final List<String> addons;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (application.exhibitorName != null)
                  Text(application.exhibitorName!),
                for (final addon in addons) Text(addon),
                const SizedBox(height: 6),
                Text(
                  'Total RM ${application.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
