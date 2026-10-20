import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/recipe_access.dart';
import 'package:healthy_cook_api/src/http/recipe_input_parser.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/recipe_repository.dart';
import 'package:healthy_cook_api/src/services/image_storage.dart';

/// GET /recipes/:id
/// PATCH /recipes/:id — só os campos enviados (apenas o autor)
/// DELETE /recipes/:id — apenas o autor
Future<Response> onRequest(RequestContext context, String id) async {
  final userId = requireUserId(context);
  final recipeId = parseId(id);
  final recipes = RecipeRepository(context.read<Database>());

  switch (context.request.method) {
    case HttpMethod.get:
      final recipe = await recipes.findById(recipeId, viewerId: userId);
      if (recipe == null) {
        throw const ApiException.notFound('Receita não encontrada');
      }
      return Response.json(body: recipe.toJson());

    case HttpMethod.patch:
      await requireOwnRecipe(recipes, recipeId, userId);
      final input = parseRecipeInput(
        await readJsonObject(context),
        partial: true,
      );
      await recipes.update(recipeId, input);
      final updated = await recipes.findById(recipeId, viewerId: userId);
      return Response.json(body: updated!.toJson());

    case HttpMethod.delete:
      final recipe = await requireOwnRecipe(recipes, recipeId, userId);
      await recipes.delete(recipeId);
      await context.read<ImageStorage>().deleteByUrl(recipe.imageUrl);
      return Response(statusCode: HttpStatus.noContent);

    default:
      throw const ApiException.methodNotAllowed();
  }
}
