import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// Imagem de uma receita, com um ícone no lugar quando ela falta ou falha.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFE8F5EC),
      alignment: Alignment.center,
      child: const Icon(LineIcons.image, size: 48, color: Color(0xFF1C4036)),
    );
    final image = url == null
        ? placeholder
        : Image.network(
            url!,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => placeholder,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
          );
    return borderRadius == null
        ? image
        : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
