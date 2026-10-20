import 'package:healthy_cook_api/src/db/database.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.photoUrl,
    required this.emailVerifiedAt,
    required this.createdAt,
  });

  factory User.fromRow(Row row) => User(
    id: row.intValue('id'),
    name: row.stringValue('name'),
    email: row.stringValue('email'),
    passwordHash: row.stringValue('password_hash'),
    photoUrl: row['photo_url'],
    emailVerifiedAt: row.nullableDateTime('email_verified_at'),
    createdAt: row.dateTimeValue('created_at'),
  );

  final int id;
  final String name;
  final String email;
  final String passwordHash;
  final String? photoUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  bool get emailVerified => emailVerifiedAt != null;

  /// Representação pública (nunca inclui o hash da senha).
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'emailVerified': emailVerified,
    'createdAt': createdAt.toIso8601String(),
  };
}
