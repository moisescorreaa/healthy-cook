import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/security/jwt_service.dart';

/// Lê o corpo da requisição como um objeto JSON.
Future<Map<String, dynamic>> readJsonObject(RequestContext context) async {
  final body = await context.request.body();
  if (body.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
  } on FormatException {
    // tratado abaixo
  }
  throw const ApiException.badRequest('Corpo da requisição deve ser um JSON');
}

/// Retorna o id do usuário autenticado pelo header `Authorization: Bearer`.
int requireUserId(RequestContext context) {
  final header = context.request.headers['authorization'];
  if (header == null || !header.startsWith('Bearer ')) {
    throw const ApiException.unauthorized();
  }
  final userId = context.read<JwtService>().verifyAccessToken(
    header.substring('Bearer '.length).trim(),
  );
  if (userId == null) {
    throw const ApiException.unauthorized('Token inválido ou expirado');
  }
  return userId;
}

/// Converte o parâmetro de rota `[id]` em inteiro.
int parseId(String id) {
  final value = int.tryParse(id);
  if (value == null || value <= 0) throw const ApiException.notFound();
  return value;
}

/// Valida campos de texto obrigatórios, acumulando erros por campo.
class Validator {
  Validator(this._data);

  final Map<String, dynamic> _data;
  final _errors = <String, String>{};

  String? string(
    String field, {
    bool required = true,
    int minLength = 1,
    int? maxLength,
  }) {
    final raw = _data[field];
    if (raw == null) {
      if (required) _errors[field] = 'Campo obrigatório';
      return null;
    }
    if (raw is! String) {
      _errors[field] = 'Deve ser texto';
      return null;
    }
    final value = raw.trim();
    if (value.length < minLength) {
      _errors[field] = minLength <= 1
          ? 'Campo obrigatório'
          : 'Deve ter pelo menos $minLength caracteres';
      return null;
    }
    if (maxLength != null && value.length > maxLength) {
      _errors[field] = 'Deve ter no máximo $maxLength caracteres';
      return null;
    }
    return value;
  }

  String? email(String field) {
    final value = string(field, maxLength: 255);
    if (value == null) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      _errors[field] = 'E-mail inválido';
      return null;
    }
    return value.toLowerCase();
  }

  /// Senha não passa por trim: espaços fazem parte dela.
  String? password(String field) {
    final value = _data[field];
    if (value is! String || value.length < 8) {
      _errors[field] = 'A senha deve ter pelo menos 8 caracteres';
      return null;
    }
    if (value.length > 72) {
      // limite do bcrypt
      _errors[field] = 'A senha deve ter no máximo 72 caracteres';
      return null;
    }
    return value;
  }

  int? positiveInt(String field, {bool required = true, int max = 100000}) {
    final raw = _data[field];
    if (raw == null) {
      if (required) _errors[field] = 'Campo obrigatório';
      return null;
    }
    final value = raw is int ? raw : int.tryParse('$raw');
    if (value == null || value <= 0 || value > max) {
      _errors[field] = 'Deve ser um número inteiro positivo';
      return null;
    }
    return value;
  }

  bool has(String field) => _data.containsKey(field);

  /// Lança [ApiException] se algum campo for inválido.
  void check() {
    if (_errors.isNotEmpty) {
      throw ApiException.badRequest(
        'Dados inválidos',
        details: Map.unmodifiable(_errors),
      );
    }
  }
}
