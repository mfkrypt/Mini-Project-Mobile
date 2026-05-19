import 'package:flutter/material.dart';

import '../models/exhibition_event.dart';
import 'exhibition_image_placeholder.dart';
import 'info_line.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onTap});

  final ExhibitionEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 153,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            const Expanded(flex: 46, child: ExhibitionImagePlaceholder()),
            Expanded(
              flex: 54,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 13, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    InfoLine(
                      icon: Icons.calendar_month,
                      text: '${event.startDate} - ${event.endDate}',
                    ),
                    const SizedBox(height: 8),
                    InfoLine(
                      icon: Icons.location_on_outlined,
                      text: event.venue,
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: 68,
                      height: 14,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: event.statusColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        event.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
