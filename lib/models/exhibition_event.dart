import 'package:flutter/material.dart';

class ExhibitionEvent {
  const ExhibitionEvent({
    required this.title,
    required this.date,
    required this.venue,
    required this.status,
    required this.statusColor,
  });

  final String title;
  final String date;
  final String venue;
  final String status;
  final Color statusColor;
}
