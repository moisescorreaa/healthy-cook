import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';

/// PUT /users/me/password — `{currentPassword, newPassword}`
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    throw const ApiException.methodNotAllowed();
  }
  final userId = requireUserId(context);
  final v = Validator(await readJsonObject(context));
  final currentPassword = v.string('currentPassword');
  final newPassword = v.password('newPassword');
  v.check();

  await context.read<AuthService>().changePassword(
    userId: userId,
    currentPassword: currentPassword!,
    newPassword: newPassword!,
  );
  return Response(statusCode: HttpStatus.noContent);
}
