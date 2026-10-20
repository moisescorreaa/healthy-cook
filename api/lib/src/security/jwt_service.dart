import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Emite e valida os access tokens (JWT HS256, de curta duração).
class JwtService {
  JwtService({required String secret, required this.accessTokenTtl})
    : _key = SecretKey(secret);

  static const _issuer = 'healthy-cook-api';

  final SecretKey _key;
  final Duration accessTokenTtl;

  String issueAccessToken(int userId) {
    return JWT(
      {'type': 'access'},
      subject: '$userId',
      issuer: _issuer,
    ).sign(_key, expiresIn: accessTokenTtl);
  }

  /// Retorna o id do usuário, ou `null` se o token for inválido ou expirado.
  int? verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(token, _key, issuer: _issuer);
      final payload = jwt.payload;
      if (payload is! Map || payload['type'] != 'access') return null;
      return int.tryParse(jwt.subject ?? '');
    } on JWTException {
      return null;
    }
  }
}
