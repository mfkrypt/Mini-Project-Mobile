import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_map.dart';
import '../../models/admin_event.dart';
import '../../utils/asset_path.dart';
import '../../widgets/phone_frame.dart';

class OrganizerBoothAssignmentPage extends StatefulWidget {
  const OrganizerBoothAssignmentPage({
    super.key,
    required this.event,
    required this.organizerId,
  });

  final AdminEvent event;
  final int organizerId;

  @override
  State<OrganizerBoothAssignmentPage> createState() =>
      _OrganizerBoothAssignmentPageState();
}

class _OrganizerBoothAssignmentPageState
    extends State<OrganizerBoothAssignmentPage> {
  final db = AdminDatabase.instance;
  List<AdminBoothMap> booths = [];
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final eventId = widget.event.id;
    if (eventId == null) return;
    final plan = await db.fetchFloorPlanForEvent(eventId);
    final maps = await db.fetchBoothsForEvent(eventId);
    if (!mounted) return;
    setState(() {
      imagePath = plan?.imagePath;
      booths = maps;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xff55bd69);
      case 'booked':
        return const Color(0xffd9534f);
      case 'pending':
        return const Color(0xfff0ad4e);
      case 'unavailable':
        return const Color(0xff9b9b9b);
      default:
        return const Color(0xff9b9b9b);
    }
  }

  // A → Standard, B → Premium, C → Corner
  String _typeNameForPrefix(String prefix) {
    switch (prefix.toUpperCase()) {
      case 'A':
        return 'Standard';
      case 'B':
        return 'Premium';
      case 'C':
        return 'Corner';
      default:
        return prefix;
    }
  }

  // Group booths by letter prefix, sorted alphabetically
  Map<String, List<AdminBoothMap>> _groupBySection() {
    final Map<String, List<AdminBoothMap>> groups = {};
    final regex = RegExp(r'^([A-Za-z]+)');
    for (final booth in booths) {
      final match = regex.firstMatch(booth.boothId);
      final prefix = (match?.group(1) ?? booth.boothId).toUpperCase();
      groups.putIfAbsent(prefix, () => []).add(booth);
    }
    for (final list in groups.values) {
      list.sort((a, b) {
        final numA = int.tryParse(
              RegExp(r'(\d+)$').firstMatch(a.boothId)?.group(1) ?? '',
            ) ??
            0;
        final numB = int.tryParse(
              RegExp(r'(\d+)$').firstMatch(b.boothId)?.group(1) ?? '',
            ) ??
            0;
        return numA.compareTo(numB);
      });
    }
    return Map.fromEntries(
      groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  // "A1" if only one booth, "A1 - A3" if multiple
  String _sectionLabel(String prefix, List<AdminBoothMap> section) {
    if (section.isEmpty) return prefix;
    if (section.length == 1) return section.first.boothId;
    return '${section.first.boothId} - ${section.last.boothId}';
  }

  Future<void> _toggleSectionAvailability(
    List<AdminBoothMap> section,
    bool available,
  ) async {
    final newStatus = available ? 'available' : 'unavailable';
    for (final booth in section) {
      if (booth.id == null) continue;
      if (booth.status == 'available' || booth.status == 'unavailable') {
        await db.updateBoothStatus(booth.id!, newStatus);
      }
    }
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupBySection();

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

            // Floor plan with booth overlays
            Container(
              height: 240,
              margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: imagePath == null
                  ? const Center(child: Text('No floor plan uploaded.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                normalizeFloorPlanAssetPath(imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, stackTrace) =>
                                    const Center(
                                      child: Text('Image not found'),
                                    ),
                              ),
                            ),
                            for (final booth in booths)
                              Positioned(
                                left: booth.x * w,
                                top: booth.y * h,
                                width: booth.width * w,
                                height: booth.height * h,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _statusColor(booth.status),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    booth.boothId,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),

            // Floor plan label
            Container(
              padding: const EdgeInsets.all(8),
              color: const Color(0xffd9d9d9),
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: const Text(
                'Floor Plan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),

            // Color legend
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Wrap(
                spacing: 14,
                runSpacing: 4,
                children: const [
                  _LegendDot(color: Color(0xff55bd69), label: 'Available'),
                  _LegendDot(color: Color(0xffd9534f), label: 'Booked'),
                  _LegendDot(color: Color(0xfff0ad4e), label: 'Pending'),
                  _LegendDot(color: Color(0xff9b9b9b), label: 'Unavailable'),
                ],
              ),
            ),

            // Booth Section heading
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                'Booth Section',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),

            if (booths.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Text('No booths assigned yet.'),
              )
            else
              for (final entry in groups.entries)
                _SectionCard(
                  label: _sectionLabel(entry.key, entry.value),
                  typeName: _typeNameForPrefix(entry.key),
                  section: entry.value,
                  onAvailabilityChanged: (val) =>
                      _toggleSectionAvailability(entry.value, val),
                ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.label,
    required this.typeName,
    required this.section,
    required this.onAvailabilityChanged,
  });

  final String label;
  final String typeName;
  final List<AdminBoothMap> section;
  final void Function(bool) onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final allAvailable = section.every((b) => b.status == 'available');

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                typeName,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const Spacer(),
              const Text('Available'),
              Switch(
                value: allAvailable,
                onChanged: onAvailabilityChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
