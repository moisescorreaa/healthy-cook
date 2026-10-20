import 'package:healthy_cook_api/src/db/database.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.howToPrepare,
    required this.timeToPrepareMin,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.likesCount,
    required this.likedByMe,
  });

  factory Recipe.fromRow(Row row) => Recipe(
    id: row.intValue('id'),
    userId: row.intValue('user_id'),
    title: row.stringValue('title'),
    description: row.stringValue('description'),
    ingredients: row.stringValue('ingredients'),
    howToPrepare: row.stringValue('how_to_prepare'),
    timeToPrepareMin: row.intValue('time_to_prepare_min'),
    imageUrl: row['image_url'],
    createdAt: row.dateTimeValue('created_at'),
    updatedAt: row.dateTimeValue('updated_at'),
    authorName: row.stringValue('author_name'),
    authorPhotoUrl: row['author_photo_url'],
    likesCount: row.intValue('likes_count'),
    likedByMe: row.intValue('liked_by_me') > 0,
  );

  final int id;
  final int userId;
  final String title;
  final String description;
  final String ingredients;
  final String howToPrepare;
  final int timeToPrepareMin;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorName;
  final String? authorPhotoUrl;
  final int likesCount;
  final bool likedByMe;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'ingredients': ingredients,
    'howToPrepare': howToPrepare,
    'timeToPrepareMin': timeToPrepareMin,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'author': {
      'id': userId,
      'name': authorName,
      'photoUrl': authorPhotoUrl,
    },
    'likesCount': likesCount,
    'likedByMe': likedByMe,
  };
}
