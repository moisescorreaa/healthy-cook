import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Libera o acesso da API a partir do navegador (app Flutter web).
/// A autenticação usa o header `Authorization`, sem cookies.
Middleware cors(List<String> allowedOrigins) {
  return (handler) {
    if (allowedOrigins.isEmpty) return handler;
    final allowAny = allowedOrigins.contains('*');

    return (context) async {
      final origin = context.request.headers['origin'];
      final allowed =
          origin != null && (allowAny || allowedOrigins.contains(origin));
      final headers = {
        if (allowed) ...{
          'access-control-allow-origin': allowAny ? '*' : origin,
          'access-control-allow-methods': 'GET, POST, PUT, PATCH, DELETE',
          'access-control-allow-headers': 'authorization, content-type',
          'access-control-max-age': '600',
          if (!allowAny) 'vary': 'origin',
        },
      };

      if (context.request.method == HttpMethod.options) {
        return Response(statusCode: HttpStatus.noContent, headers: headers);
      }
      final response = await handler(context);
      return response.copyWith(headers: {...response.headers, ...headers});
    };
  };
}
