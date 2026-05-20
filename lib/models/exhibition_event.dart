import 'package:flutter/material.dart';

class ExhibitionEvent {
  const ExhibitionEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.status,
    required this.statusColor,
  });

  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final String venue;
  final String status;
  final Color statusColor;
}
