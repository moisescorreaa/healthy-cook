import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/recipe_access.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/recipe_repository.dart';
import 'package:healthy_cook_api/src/services/image_storage.dart';

/// PUT /recipes/:id/image — multipart com o campo `image` (apenas o autor).
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put) {
    throw const ApiException.methodNotAllowed();
  }
  final userId = requireUserId(context);
  final recipeId = parseId(id);
  final recipes = RecipeRepository(context.read<Database>());
  final images = context.read<ImageStorage>();

  final recipe = await requireOwnRecipe(recipes, recipeId, userId);
  final url = await images.save(context.request, folder: 'recipes/$recipeId');
  await recipes.updateImage(recipeId, url);
  await images.deleteByUrl(recipe.imageUrl);

  final updated = await recipes.findById(recipeId, viewerId: userId);
  return Response.json(body: updated!.toJson());
}
