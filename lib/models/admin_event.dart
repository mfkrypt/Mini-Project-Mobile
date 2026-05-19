class AdminEvent {
  const AdminEvent({
    this.id,
    required this.name,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.isPublished,
    required this.organizerId,
    required this.blockAdjacent,
  });

  final int? id;
  final String name;
  final String venue;
  final String startDate;
  final String endDate;
  final bool isPublished;
  final int organizerId;
  final bool blockAdjacent;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'venue': venue,
      'start_date': startDate,
      'end_date': endDate,
      'is_published': isPublished ? 1 : 0,
      'organizer_id': organizerId,
      'block_adjacent': blockAdjacent ? 1 : 0,
    };
  }

  static AdminEvent fromMap(Map<String, Object?> map) {
    return AdminEvent(
      id: map['id'] as int?,
      name: map['name'] as String,
      venue: map['venue'] as String? ?? 'TBD',
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      isPublished: (map['is_published'] as int) == 1,
      organizerId: map['organizer_id'] as int? ?? 0,
      blockAdjacent: (map['block_adjacent'] as int? ?? 0) == 1,
    );
  }
}
