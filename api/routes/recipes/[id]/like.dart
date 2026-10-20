import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/recipe_repository.dart';

/// PUT /recipes/:id/like — curtir
/// DELETE /recipes/:id/like — descurtir
/// Ambos retornam `{likesCount, likedByMe}` atualizados.
Future<Response> onRequest(RequestContext context, String id) async {
  final userId = requireUserId(context);
  final recipeId = parseId(id);
  final recipes = RecipeRepository(context.read<Database>());

  if (await recipes.findById(recipeId, viewerId: userId) == null) {
    throw const ApiException.notFound('Receita não encontrada');
  }

  switch (context.request.method) {
    case HttpMethod.put:
      await recipes.like(recipeId, userId);
    case HttpMethod.delete:
      await recipes.unlike(recipeId, userId);
    default:
      throw const ApiException.methodNotAllowed();
  }

  final recipe = await recipes.findById(recipeId, viewerId: userId);
  return Response.json(
    body: {'likesCount': recipe!.likesCount, 'likedByMe': recipe.likedByMe},
  );
}
