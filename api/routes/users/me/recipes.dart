import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/pagination.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/recipe_repository.dart';

/// GET /users/me/recipes?limit=&offset= — receitas do usuário logado.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    throw const ApiException.methodNotAllowed();
  }
  final userId = requireUserId(context);
  final page = readPagination(context);
  final recipes = await RecipeRepository(context.read<Database>()).listByUser(
    userId,
    viewerId: userId,
    limit: page.limit,
    offset: page.offset,
  );
  return Response.json(
    body: {
      'items': [for (final r in recipes) r.toJson()],
    },
  );
}
