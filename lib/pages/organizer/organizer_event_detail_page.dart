import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_type.dart';
import '../../models/admin_event.dart';
import '../../widgets/phone_frame.dart';
import 'organizer_booth_assignment_page.dart';
import 'organizer_booth_form_page.dart';
import 'organizer_requests_page.dart';

class OrganizerEventDetailPage extends StatefulWidget {
  const OrganizerEventDetailPage({
    super.key,
    required this.event,
    required this.organizerId,
  });

  final AdminEvent event;
  final int organizerId;

  @override
  State<OrganizerEventDetailPage> createState() =>
      _OrganizerEventDetailPageState();
}

class _OrganizerEventDetailPageState extends State<OrganizerEventDetailPage> {
  final db = AdminDatabase.instance;
  List<AdminBoothType> boothTypes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final eventId = widget.event.id;
    if (eventId == null) return;
    final types = await db.fetchBoothTypesForEvent(eventId);
    if (!mounted) return;
    setState(() => boothTypes = types);
  }

  Future<void> _removeBooth(AdminBoothType booth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Booth Type'),
        content: Text(
          'Remove "${booth.name}" from this event? '
          'This will also delete its booth maps and any related applications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true && booth.id != null) {
      await db.deleteBoothType(booth.id!);
      _loadData();
    }
  }

  void _openRequests() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: OrganizerRequestsPage(
            organizerId: widget.organizerId,
            eventId: widget.event.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
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
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${event.startDate} - ${event.endDate}'),
                  const SizedBox(height: 4),
                  Text('Location: ${event.venue}'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Booth Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: event.id == null
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrganizerBoothAssignmentPage(
                                    event: event,
                                    organizerId: widget.organizerId,
                                  ),
                                ),
                              ),
                        icon: const Icon(Icons.grid_view_outlined, size: 16),
                        label: const Text('Assign'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: event.id == null
                        ? null
                        : () async {
                            final result = await Navigator.of(context)
                                .push<bool>(
                              MaterialPageRoute(
                                builder: (_) => OrganizerBoothFormPage(
                                  eventId: event.id!,
                                ),
                              ),
                            );
                            if (result == true) _loadData();
                          },
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xffd9d9d9),
                          width: 2,
                        ),
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
                  const SizedBox(height: 14),
                  if (boothTypes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: Text('No booth types yet.')),
                    )
                  else
                    for (final booth in boothTypes)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xfff1ecec),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                booth.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _openRequests,
                              child: const Text('Approval'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _removeBooth(booth),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
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
