import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';

/// GET /auth/verify-email?token=... — link enviado por e-mail.
/// Responde com uma página simples, pois é aberto no navegador.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    throw const ApiException.methodNotAllowed();
  }
  final token = context.request.uri.queryParameters['token'] ?? '';
  final verified =
      token.isNotEmpty && await context.read<AuthService>().verifyEmail(token);

  final message = verified
      ? 'E-mail confirmado! Você já pode voltar ao app Healthy Cook.'
      : 'Link inválido ou expirado. Solicite um novo pelo app.';
  return Response(
    statusCode: verified ? HttpStatus.ok : HttpStatus.badRequest,
    headers: {HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8'},
    body:
        '''
<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>Healthy Cook</title>
<body style="font-family:sans-serif;text-align:center;padding:48px">
  <h1>Healthy Cook</h1>
  <p>$message</p>
</body>
''',
  );
}
