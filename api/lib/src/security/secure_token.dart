import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

final _random = Random.secure();

/// Gera um token aleatório (256 bits) seguro para URLs.
String generateSecureToken() {
  final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Hash SHA-256 em hexadecimal. Apenas o hash do token é salvo no banco.
String hashToken(String token) => sha256.convert(utf8.encode(token)).toString();
