class AdminReservation {
  const AdminReservation({
    this.id,
    required this.date,
    required this.email,
    required this.status,
  });

  final int? id;
  final String date;
  final String email;
  final String status;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date,
      'email': email,
      'status': status,
    };
  }

  static AdminReservation fromMap(Map<String, Object?> map) {
    return AdminReservation(
      id: map['id'] as int?,
      date: map['date'] as String,
      email: map['email'] as String,
      status: map['status'] as String,
    );
  }
}
