/// Erro retornado pela API ou falha de comunicação com ela.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const {},
  });

  /// Falha de rede: servidor fora do ar, sem internet etc.
  const ApiException.network()
      : statusCode = 0,
        code = 'network_error',
        message = 'Não foi possível conectar ao servidor. '
            'Verifique sua conexão e tente novamente.',
        details = const {};

  factory ApiException.fromResponse(int statusCode, Object? body) {
    final error = body is Map<String, dynamic> ? body['error'] : null;
    if (error is Map<String, dynamic>) {
      final details = error['details'];
      return ApiException(
        statusCode: statusCode,
        code: error['code'] as String? ?? 'unknown',
        message: error['message'] as String? ?? 'Erro inesperado',
        details: details is Map
            ? details.map((key, value) => MapEntry('$key', '$value'))
            : const {},
      );
    }
    return ApiException(
      statusCode: statusCode,
      code: 'unknown',
      message: 'Erro inesperado do servidor ($statusCode)',
    );
  }

  final int statusCode;

  /// Código estável enviado pela API (ex.: `email_in_use`).
  final String code;
  final String message;

  /// Erros de validação por campo.
  final Map<String, String> details;

  /// Mensagem para exibir ao usuário, incluindo o primeiro erro de campo.
  String get userMessage =>
      details.isEmpty ? message : '$message: ${details.values.first}';

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
