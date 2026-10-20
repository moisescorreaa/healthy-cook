import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';

/// POST /auth/reset-password — `{token, password}`
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    throw const ApiException.methodNotAllowed();
  }
  final v = Validator(await readJsonObject(context));
  final token = v.string('token');
  final password = v.password('password');
  v.check();

  await context.read<AuthService>().resetPassword(
    token: token!,
    newPassword: password!,
  );
  return Response(statusCode: HttpStatus.noContent);
}
