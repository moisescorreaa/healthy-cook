import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';

/// POST /auth/register — `{name, email, password}`
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    throw const ApiException.methodNotAllowed();
  }
  final v = Validator(await readJsonObject(context));
  final name = v.string('name', minLength: 2, maxLength: 100);
  final email = v.email('email');
  final password = v.password('password');
  v.check();

  final result = await context.read<AuthService>().register(
    name: name!,
    email: email!,
    password: password!,
  );
  return Response.json(statusCode: HttpStatus.created, body: result.toJson());
}
