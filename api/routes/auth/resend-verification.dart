import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/user_repository.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';

/// POST /auth/resend-verification (autenticado)
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    throw const ApiException.methodNotAllowed();
  }
  final userId = requireUserId(context);
  final user = await UserRepository(context.read<Database>()).findById(userId);
  if (user == null) throw const ApiException.unauthorized();

  await context.read<AuthService>().sendEmailVerification(user);
  return Response(statusCode: HttpStatus.noContent);
}
