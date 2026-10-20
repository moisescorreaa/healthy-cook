class RecipeAuthor {
  const RecipeAuthor({
    required this.id,
    required this.name,
    required this.photoUrl,
  });

  final int id;
  final String name;
  final String? photoUrl;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.howToPrepare,
    required this.timeToPrepareMin,
    required this.imageUrl,
    required this.createdAt,
    required this.author,
    required this.likesCount,
    required this.likedByMe,
  });

  factory Recipe.fromJson(
    Map<String, dynamic> json,
    String? Function(String?) resolveUrl,
  ) {
    final author = json['author'] as Map<String, dynamic>;
    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: json['ingredients'] as String,
      howToPrepare: json['howToPrepare'] as String,
      timeToPrepareMin: json['timeToPrepareMin'] as int,
      imageUrl: resolveUrl(json['imageUrl'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: RecipeAuthor(
        id: author['id'] as int,
        name: author['name'] as String,
        photoUrl: resolveUrl(author['photoUrl'] as String?),
      ),
      likesCount: json['likesCount'] as int,
      likedByMe: json['likedByMe'] as bool,
    );
  }

  final int id;
  final String title;
  final String description;
  final String ingredients;
  final String howToPrepare;
  final int timeToPrepareMin;
  final String? imageUrl;
  final DateTime createdAt;
  final RecipeAuthor author;
  final int likesCount;
  final bool likedByMe;

  Recipe withLikes({required int likesCount, required bool likedByMe}) =>
      Recipe(
        id: id,
        title: title,
        description: description,
        ingredients: ingredients,
        howToPrepare: howToPrepare,
        timeToPrepareMin: timeToPrepareMin,
        imageUrl: imageUrl,
        createdAt: createdAt,
        author: author,
        likesCount: likesCount,
        likedByMe: likedByMe,
      );
}

/// Campos editáveis de uma receita.
class RecipeDraft {
  const RecipeDraft({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.howToPrepare,
    required this.timeToPrepareMin,
  });

  final String title;
  final String description;
  final String ingredients;
  final String howToPrepare;
  final int timeToPrepareMin;

  Map<String, Object> toJson() => {
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'howToPrepare': howToPrepare,
        'timeToPrepareMin': timeToPrepareMin,
      };
}
