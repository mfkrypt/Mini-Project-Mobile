class AdminUser {
  const AdminUser({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.passwordHash,
  });

  final int? id;
  final String name;
  final String email;
  final String role;
  final String? passwordHash;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'password_hash': passwordHash,
    };
  }

  static AdminUser fromMap(Map<String, Object?> map) {
    return AdminUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      passwordHash: map['password_hash'] as String?,
    );
  }
}
