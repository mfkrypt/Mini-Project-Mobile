class AdminBoothType {
  const AdminBoothType({
    this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.available,
    required this.count,
  });

  final int? id;
  final int eventId;
  final String name;
  final double price;
  final bool available;
  final int count;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'price': price,
      'available': available ? 1 : 0,
      'count': count,
    };
  }

  static AdminBoothType fromMap(Map<String, Object?> map) {
    return AdminBoothType(
      id: map['id'] as int?,
      eventId: map['event_id'] as int? ?? 0,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      available: (map['available'] as int) == 1,
      count: map['count'] as int,
    );
  }
}
