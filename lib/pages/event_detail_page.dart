import 'package:flutter/material.dart';

import '../data/admin_database.dart';
import '../models/admin_booth_type.dart';
import '../models/admin_floor_plan.dart';
import '../models/exhibition_event.dart';
import '../widgets/divider_line.dart';
import '../widgets/floor_plan_preview.dart';
import '../widgets/phone_frame.dart';
import '../widgets/primary_button.dart';
import 'login_page.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.event});

  final ExhibitionEvent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhoneFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DividerLine(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 40, 0, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 58,
                  height: 42,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffdddddd),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                ),
              ),
            ),
            const DividerLine(),
            Expanded(
              child: FutureBuilder<_EventDetailData>(
                future: _loadDetail(event.id),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Date: ${event.startDate} - ${event.endDate}',
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Venue: ${event.venue}',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      const DividerLine(),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(14, 12, 14, 2),
                        child: Text(
                          'Visual Floor Plan (Read-Only)',
                          style: TextStyle(fontSize: 21),
                        ),
                      ),
                      FloorPlanPreview(imagePath: data?.plan?.imagePath),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                        child: _BoothInfoCard(types: data?.types ?? []),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 0, 50, 22),
                        child: PrimaryButton(
                          label: 'Login to Book Booth',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_EventDetailData> _loadDetail(int eventId) async {
    final db = AdminDatabase.instance;
    final plan = await db.fetchFloorPlanForEvent(eventId);
    final types = await db.fetchBoothTypesForEvent(eventId);
    return _EventDetailData(plan: plan, types: types);
  }
}

class _EventDetailData {
  const _EventDetailData({required this.plan, required this.types});

  final AdminFloorPlan? plan;
  final List<AdminBoothType> types;
}

class _BoothInfoCard extends StatelessWidget {
  const _BoothInfoCard({required this.types});

  final List<AdminBoothType> types;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xffdddddd),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booth Information:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (types.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 17),
              child: Text(
                'No booth types defined yet.',
                style: TextStyle(fontSize: 16, height: 1.42),
              ),
            ),
          if (types.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: types
                    .map(
                      (type) => Text(
                        '${type.name}: RM ${type.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, height: 1.42),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
