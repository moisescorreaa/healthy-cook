import 'dart:io';

/// Erro esperado da API, convertido em resposta JSON pelo middleware.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.code, this.message, {this.details});

  const ApiException.badRequest(String message, {Map<String, String>? details})
    : this(HttpStatus.badRequest, 'bad_request', message, details: details);

  const ApiException.unauthorized([String message = 'Não autenticado'])
    : this(HttpStatus.unauthorized, 'unauthorized', message);

  const ApiException.forbidden([String message = 'Acesso negado'])
    : this(HttpStatus.forbidden, 'forbidden', message);

  const ApiException.notFound([String message = 'Recurso não encontrado'])
    : this(HttpStatus.notFound, 'not_found', message);

  const ApiException.conflict(String code, String message)
    : this(HttpStatus.conflict, code, message);

  const ApiException.methodNotAllowed()
    : this(
        HttpStatus.methodNotAllowed,
        'method_not_allowed',
        'Método não permitido',
      );

  final int statusCode;

  /// Código estável para o app tratar o erro (ex.: `email_in_use`).
  final String code;
  final String message;

  /// Erros por campo, usados em validações de formulário.
  final Map<String, String>? details;

  Map<String, Object?> toJson() => {
    'error': {
      'code': code,
      'message': message,
      if (details != null) 'details': details,
    },
  };

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
