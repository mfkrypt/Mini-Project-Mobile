import 'package:flutter/material.dart';

import '../models/exhibition_event.dart';
import '../widgets/booth_information.dart';
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
              child: ListView(
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
                          'Date: ${event.date}',
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
                  const FloorPlanPreview(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: BoothInformation(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 0, 50, 22),
                    child: PrimaryButton(
                      label: 'Login to Book Booth',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
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
