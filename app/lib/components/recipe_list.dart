import 'package:flutter/material.dart';
import 'package:healthy_cook/components/async_recipes.dart';
import 'package:healthy_cook/components/recipe_detail.dart';
import 'package:healthy_cook/components/recipe_image.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';

/// Receitas do usuário logado, exibidas no perfil.
class RecipeList extends StatefulWidget {
  const RecipeList({super.key});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> with RecipeListLoader {
  @override
  Future<List<Recipe>> fetch(RecipeRepository recipes) => recipes.mine();

  void navigateToRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeDetail(recipe: recipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = items;
    if (recipes == null) {
      return error != null
          ? LoadError(message: error!, onRetry: reload)
          : const Center(child: CircularProgressIndicator());
    }
    if (recipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Você ainda não publicou receitas'),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () => navigateToRecipeDetail(recipe),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImage(url: recipe.imageUrl),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.75),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          recipe.title,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
