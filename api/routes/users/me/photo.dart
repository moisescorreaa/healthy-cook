import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/user_repository.dart';
import 'package:healthy_cook_api/src/services/image_storage.dart';

/// PUT /users/me/photo — multipart com o campo `image`.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    throw const ApiException.methodNotAllowed();
  }
  final userId = requireUserId(context);
  final users = UserRepository(context.read<Database>());
  final images = context.read<ImageStorage>();

  final previous = await users.findById(userId);
  if (previous == null) throw const ApiException.unauthorized();

  final url = await images.save(context.request, folder: 'users/$userId');
  await users.updateProfile(userId, photoUrl: url);
  await images.deleteByUrl(previous.photoUrl);

  final user = await users.findById(userId);
  return Response.json(body: user!.toJson());
}
