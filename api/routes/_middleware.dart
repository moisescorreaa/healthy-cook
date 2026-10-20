import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/security/jwt_service.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';
import 'package:healthy_cook_api/src/services/image_storage.dart';

import '../main.dart';

Handler middleware(Handler handler) {
  return handler
      .use(_errorHandler)
      .use(provider<ImageStorage>((_) => services.images))
      .use(provider<AuthService>((_) => services.auth))
      .use(provider<JwtService>((_) => services.jwt))
      .use(provider<Database>((_) => services.db))
      .use(requestLogger());
}

/// Converte exceções em respostas JSON padronizadas.
Handler _errorHandler(Handler handler) {
  return (context) async {
    try {
      return await handler(context);
    } on ApiException catch (e) {
      return Response.json(statusCode: e.statusCode, body: e.toJson());
    } catch (e, stack) {
      stderr.writeln('Erro não tratado: $e\n$stack');
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: const ApiException(
          HttpStatus.internalServerError,
          'internal_error',
          'Erro interno do servidor',
        ).toJson(),
      );
    }
  };
}
