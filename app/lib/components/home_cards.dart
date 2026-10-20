import 'package:flutter/material.dart';
import 'package:healthy_cook/components/async_recipes.dart';
import 'package:healthy_cook/components/like_button.dart';
import 'package:healthy_cook/components/recipe_detail.dart';
import 'package:healthy_cook/components/recipe_image.dart';
import 'package:healthy_cook/components/user_avatar.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';

class HomeFeed extends StatefulWidget {
  final DateTime? date;

  const HomeFeed({super.key, required this.date});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> with RecipeListLoader {
  @override
  Future<List<Recipe>> fetch(RecipeRepository recipes) =>
      recipes.feed(since: widget.date);

  @override
  void didUpdateWidget(HomeFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      setState(() => items = null);
      reload();
    }
  }

  Future<void> navigateToRecipeDetail(Recipe recipe) async {
    final updated = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (context) => RecipeDetail(recipe: recipe)),
    );
    if (updated != null) replaceItem(updated);
  }

  @override
  Widget build(BuildContext context) {
    final recipes = items;
    return Expanded(
      child: RefreshIndicator(
        onRefresh: reload,
        child: recipes == null
            ? ListView(
                children: [
                  if (error != null)
                    LoadError(message: error!, onRetry: reload)
                  else
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              )
            : recipes.isEmpty
                ? ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('Nenhuma receita publicada no período'),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) => _buildCard(recipes[index]),
                  ),
      ),
    );
  }

  Widget _buildCard(Recipe recipe) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                UserAvatar(photoUrl: recipe.author.photoUrl, radius: 10),
                const SizedBox(width: 8),
                Text(
                  recipe.author.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: RecipeImage(url: recipe.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LikeButton(recipe: recipe, onChanged: replaceItem),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed: () => navigateToRecipeDetail(recipe),
                    child: const Text(
                      'Ver receita',
                      style: TextStyle(
                        color: Color(0xFF1D7332),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
