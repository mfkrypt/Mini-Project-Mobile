class AdminBoothMap {
  const AdminBoothMap({
    this.id,
    required this.boothId,
    required this.boothTypeId,
    required this.floorPlanId,
    required this.x,
    required this.y,
    required this.attributes,
  });

  final int? id;
  final String boothId;
  final int boothTypeId;
  final int floorPlanId;
  final double x;
  final double y;
  final String attributes;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'booth_id': boothId,
      'booth_type_id': boothTypeId,
      'floor_plan_id': floorPlanId,
      'x': x,
      'y': y,
      'attributes': attributes,
    };
  }

  static AdminBoothMap fromMap(Map<String, Object?> map) {
    return AdminBoothMap(
      id: map['id'] as int?,
      boothId: map['booth_id'] as String,
      boothTypeId: map['booth_type_id'] as int,
      floorPlanId: map['floor_plan_id'] as int,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      attributes: map['attributes'] as String,
    );
  }
}
