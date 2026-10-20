import 'dart:io';

import 'package:dotenv/dotenv.dart';

/// Configuração da API, lida do arquivo `.env` e das variáveis de ambiente.
///
/// Variáveis de ambiente do processo têm prioridade sobre o `.env`.
class Env {
  Env._(this._values);

  factory Env.load() {
    final dotenv = DotEnv(includePlatformEnvironment: true, quiet: true);
    if (File('.env').existsSync()) dotenv.load(['.env']);
    return Env._(dotenv);
  }

  final DotEnv _values;

  String _require(String key) {
    final value = _values[key];
    if (value == null || value.isEmpty) {
      throw StateError('Variável de ambiente obrigatória ausente: $key');
    }
    return value;
  }

  String _get(String key, String fallback) {
    final value = _values[key];
    return value == null || value.isEmpty ? fallback : value;
  }

  String get publicBaseUrl => _get('PUBLIC_BASE_URL', 'http://localhost:8080');

  String get dbHost => _get('DB_HOST', '127.0.0.1');
  int get dbPort => int.parse(_get('DB_PORT', '3306'));
  String get dbName => _require('DB_NAME');
  String get dbUser => _require('DB_USER');
  String get dbPassword => _require('DB_PASSWORD');

  String get jwtSecret {
    final secret = _require('JWT_SECRET');
    if (secret.length < 32) {
      throw StateError('JWT_SECRET deve ter pelo menos 32 caracteres');
    }
    return secret;
  }

  Duration get accessTokenTtl =>
      Duration(minutes: int.parse(_get('ACCESS_TOKEN_TTL_MINUTES', '15')));
  Duration get refreshTokenTtl =>
      Duration(days: int.parse(_get('REFRESH_TOKEN_TTL_DAYS', '30')));

  String get uploadsDir => _get('UPLOADS_DIR', 'public/uploads');

  /// Origens liberadas para CORS (separadas por vírgula), usadas pelo app
  /// rodando no navegador. `*` libera qualquer origem; vazio desativa o CORS.
  List<String> get corsAllowedOrigins => _get('CORS_ALLOWED_ORIGINS', '')
      .split(',')
      .map((origin) => origin.trim())
      .where((origin) => origin.isNotEmpty)
      .toList();
}
