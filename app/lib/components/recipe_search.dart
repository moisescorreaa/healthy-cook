import 'dart:async';

import 'package:flutter/material.dart';
import 'package:healthy_cook/components/async_recipes.dart';
import 'package:healthy_cook/components/recipe_detail.dart';
import 'package:healthy_cook/components/recipe_image.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:line_icons/line_icon.dart';
import 'package:provider/provider.dart';

/// Busca de receitas (antes feita pelo Algolia). Sem texto, mostra as mais
/// recentes; com texto, as que combinam, das mais curtidas para as menos.
class RecipeSearch extends StatefulWidget {
  const RecipeSearch({super.key});

  @override
  State<RecipeSearch> createState() => _RecipeSearchState();
}

class _RecipeSearchState extends State<RecipeSearch> {
  static const _debounce = Duration(milliseconds: 350);

  late final RecipeRepository _recipes;
  Timer? _timer;
  String _query = '';
  int _requestId = 0;

  List<Recipe>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recipes = context.read<RecipeRepository>();
    _recipes.addListener(_search);
    _search();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recipes.removeListener(_search);
    super.dispose();
  }

  void _onChanged(String value) {
    _query = value.trim();
    _timer?.cancel();
    _timer = Timer(_debounce, _search);
  }

  /// Só a resposta da busca mais recente é exibida, mesmo que uma anterior
  /// chegue depois.
  Future<void> _search() async {
    final requestId = ++_requestId;
    final query = _query;
    try {
      final results =
          query.isEmpty ? await _recipes.feed() : await _recipes.search(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = results;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _error = e.userMessage);
    }
  }

  void _openRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeDetail(recipe: recipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _onChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              _timer?.cancel();
              _search();
            },
            decoration: const InputDecoration(
              suffixIcon: LineIcon.search(),
              suffixIconColor: Color(0xFF1C4036),
              hintText: 'Digite sua busca',
            ),
          ),
        ),
        _buildResults(),
      ],
    );
  }

  Widget _buildResults() {
    final results = _results;
    if (_error != null && results == null) {
      return LoadError(message: _error!, onRetry: _search);
    }
    if (results == null) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'Não há resultados para sua pesquisa',
          ),
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (_, i) => _buildTile(results[i]),
    );
  }

  Widget _buildTile(Recipe recipe) {
    return GestureDetector(
      onTap: () => _openRecipe(recipe),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${recipe.likesCount} ${recipe.likesCount == 1 ? "curtida" : "curtidas"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
