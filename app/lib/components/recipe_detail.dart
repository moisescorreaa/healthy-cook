import 'package:flutter/material.dart';
import 'package:healthy_cook/components/edit_recipe.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/components/like_button.dart';
import 'package:healthy_cook/components/recipe_image.dart';
import 'package:healthy_cook/components/user_avatar.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:provider/provider.dart';

/// Detalhes de uma receita. Para o autor, mostra também Editar e Excluir.
///
/// Ao voltar, devolve a receita atualizada (curtidas, edição) para a tela
/// anterior.
class RecipeDetail extends StatefulWidget {
  const RecipeDetail({super.key, required this.recipe});

  /// Dados já carregados na lista, exibidos enquanto a versão atual chega.
  final Recipe recipe;

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  late Recipe _recipe = widget.recipe;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final recipe = await context.read<RecipeRepository>().get(_recipe.id);
      if (mounted) setState(() => _recipe = recipe);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 404) {
        showErrorSnackBar(context, 'Esta receita não está mais disponível');
        Navigator.of(context).pop();
      }
      // Outros erros: mantém os dados que vieram da lista.
    }
  }

  Future<void> navigateToEditDetailRecipe() async {
    final updated = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (context) => EditRecipe(recipe: _recipe)),
    );
    if (updated != null && mounted) setState(() => _recipe = updated);
  }

  Future<void> deleteRecipe() async {
    setState(() => _deleting = true);
    try {
      await context.read<RecipeRepository>().delete(_recipe.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Receita excluída com sucesso!');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      showErrorSnackBar(context, e.userMessage);
    }
  }

  Future<void> deletePopUp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Você tem certeza que deseja excluir sua receita?'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF18592F)),
                  child: const Text(
                    "Continuar",
                    style: TextStyle(color: Color(0xFFF2F2F2)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Color(0xFFF2F2F2)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true) await deleteRecipe();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    final isOwner =
        context.watch<AuthController>().user?.id == recipe.author.id;

    return PopScope<Recipe>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_recipe);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9DF6B0),
          title: const Text(
            'Detalhes da Receita',
            style: TextStyle(color: Color(0xFF1C4036)),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () => Navigator.of(context).pop(_recipe),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      LikeButton(
                        recipe: recipe,
                        onChanged: (updated) =>
                            setState(() => _recipe = updated),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.description,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ingredientes:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.ingredients,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Modo de Preparo:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.howToPrepare,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tempo de Preparo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${recipe.timeToPrepareMin} minutos",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Postado por:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          UserAvatar(
                            photoUrl: recipe.author.photoUrl,
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            recipe.author.name,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwner) _buildOwnerActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.all(10),
          child: SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: _deleting ? null : navigateToEditDetailRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18592F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Editar",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFF2F2F2)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: _deleting ? null : deletePopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Excluir",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFF2F2F2)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
