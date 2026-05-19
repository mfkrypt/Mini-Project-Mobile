class AdminFloorPlan {
  const AdminFloorPlan({
    this.id,
    required this.eventId,
    required this.title,
    required this.imagePath,
  });

  final int? id;
  final int eventId;
  final String title;
  final String imagePath;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'title': title,
      'image_path': imagePath,
    };
  }

  static AdminFloorPlan fromMap(Map<String, Object?> map) {
    return AdminFloorPlan(
      id: map['id'] as int?,
      eventId: map['event_id'] as int? ?? 0,
      title: map['title'] as String,
      imagePath: map['image_path'] as String,
    );
  }
}
