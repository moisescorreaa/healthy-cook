import 'package:flutter/material.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:provider/provider.dart';

/// Coração de curtir com o contador. Atualiza na hora e desfaz se a API
/// recusar.
class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.recipe,
    required this.onChanged,
    this.color = Colors.red,
  });

  final Recipe recipe;
  final ValueChanged<Recipe> onChanged;
  final Color color;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _sending = false;

  Future<void> _toggle() async {
    if (_sending) return;
    final before = widget.recipe;
    final liked = !before.likedByMe;
    widget.onChanged(before.withLikes(
      likesCount: before.likesCount + (liked ? 1 : -1),
      likedByMe: liked,
    ));

    setState(() => _sending = true);
    try {
      final status = await context
          .read<RecipeRepository>()
          .setLiked(before.id, liked: liked);
      widget.onChanged(before.withLikes(
        likesCount: status.likesCount,
        likedByMe: status.likedByMe,
      ));
    } on ApiException catch (e) {
      widget.onChanged(before);
      if (mounted) showErrorSnackBar(context, e.userMessage);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          color: widget.color,
          tooltip: recipe.likedByMe ? 'Descurtir' : 'Curtir',
          icon: Icon(
            recipe.likedByMe ? Icons.favorite : Icons.favorite_border,
          ),
          onPressed: _toggle,
        ),
        Text(
          '${recipe.likesCount} ${recipe.likesCount == 1 ? "curtida" : "curtidas"}',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.normal, color: widget.color),
        ),
      ],
    );
  }
}
