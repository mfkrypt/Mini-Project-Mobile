class AdminFloorPlan {
  const AdminFloorPlan({
    this.id,
    required this.title,
    required this.imagePath,
  });

  final int? id;
  final String title;
  final String imagePath;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'image_path': imagePath,
    };
  }

  static AdminFloorPlan fromMap(Map<String, Object?> map) {
    return AdminFloorPlan(
      id: map['id'] as int?,
      title: map['title'] as String,
      imagePath: map['image_path'] as String,
    );
  }
}
