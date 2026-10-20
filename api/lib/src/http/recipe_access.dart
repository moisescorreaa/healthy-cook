import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/models/recipe.dart';
import 'package:healthy_cook_api/src/repositories/recipe_repository.dart';

/// Carrega a receita e garante que [userId] é o autor.
Future<Recipe> requireOwnRecipe(
  RecipeRepository recipes,
  int recipeId,
  int userId,
) async {
  final recipe = await recipes.findById(recipeId, viewerId: userId);
  if (recipe == null) {
    throw const ApiException.notFound('Receita não encontrada');
  }
  if (recipe.userId != userId) {
    throw const ApiException.forbidden('Só o autor pode alterar esta receita');
  }
  return recipe;
}
