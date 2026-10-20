import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/user_repository.dart';

/// GET /users/me — dados do usuário logado.
/// PATCH /users/me — `{name}`
Future<Response> onRequest(RequestContext context) async {
  final userId = requireUserId(context);
  final users = UserRepository(context.read<Database>());

  switch (context.request.method) {
    case HttpMethod.get:
      break;
    case HttpMethod.patch:
      final v = Validator(await readJsonObject(context));
      final name = v.string('name', minLength: 2, maxLength: 100);
      v.check();
      await users.updateProfile(userId, name: name);
    default:
      throw const ApiException.methodNotAllowed();
  }

  final user = await users.findById(userId);
  if (user == null) throw const ApiException.unauthorized();
  return Response.json(body: user.toJson());
}
