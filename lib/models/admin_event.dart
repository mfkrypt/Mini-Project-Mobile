class AdminEvent {
  const AdminEvent({
    this.id,
    required this.name,
    required this.date,
    required this.isPublished,
  });

  final int? id;
  final String name;
  final String date;
  final bool isPublished;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'is_published': isPublished ? 1 : 0,
    };
  }

  static AdminEvent fromMap(Map<String, Object?> map) {
    return AdminEvent(
      id: map['id'] as int?,
      name: map['name'] as String,
      date: map['date'] as String,
      isPublished: (map['is_published'] as int) == 1,
    );
  }
}
