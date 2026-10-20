import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';

/// POST /auth/forgot-password — `{email}`. Sempre responde 204.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    throw const ApiException.methodNotAllowed();
  }
  final v = Validator(await readJsonObject(context));
  final email = v.email('email');
  v.check();

  await context.read<AuthService>().requestPasswordReset(email!);
  return Response(statusCode: HttpStatus.noContent);
}
