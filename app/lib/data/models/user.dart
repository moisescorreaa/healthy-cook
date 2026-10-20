class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.emailVerified,
  });

  factory User.fromJson(
    Map<String, dynamic> json,
    String? Function(String?) resolveUrl,
  ) =>
      User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        photoUrl: resolveUrl(json['photoUrl'] as String?),
        emailVerified: json['emailVerified'] as bool,
      );

  final int id;
  final String name;
  final String email;

  /// `null` quando o usuário não enviou foto.
  final String? photoUrl;
  final bool emailVerified;
}
