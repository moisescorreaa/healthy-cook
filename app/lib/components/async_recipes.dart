import 'package:flutter/material.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:provider/provider.dart';

/// Carrega uma lista de receitas e a recarrega quando o [RecipeRepository]
/// avisa que algo mudou (receita criada, editada ou excluída).
mixin RecipeListLoader<T extends StatefulWidget> on State<T> {
  late final RecipeRepository recipes;

  List<Recipe>? items;
  String? error;
  bool get isLoading => items == null && error == null;

  /// Busca a lista. Implementado por cada tela.
  Future<List<Recipe>> fetch(RecipeRepository recipes);

  @override
  void initState() {
    super.initState();
    recipes = context.read<RecipeRepository>();
    recipes.addListener(reload);
    reload();
  }

  @override
  void dispose() {
    recipes.removeListener(reload);
    super.dispose();
  }

  Future<void> reload() async {
    final request = fetch(recipes);
    try {
      final result = await request;
      if (!mounted) return;
      setState(() {
        items = result;
        error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.userMessage);
    }
  }

  /// Troca uma receita da lista (ex.: depois de curtir).
  void replaceItem(Recipe recipe) {
    setState(() {
      items = [
        for (final item in items ?? <Recipe>[])
          item.id == recipe.id ? recipe : item,
      ];
    });
  }
}

/// Mensagem de erro com botão para tentar de novo.
class LoadError extends StatelessWidget {
  const LoadError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
