import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/models/recipe.dart';

/// Campos editáveis de uma receita.
class RecipeInput {
  const RecipeInput({
    this.title,
    this.description,
    this.ingredients,
    this.howToPrepare,
    this.timeToPrepareMin,
  });

  final String? title;
  final String? description;
  final String? ingredients;
  final String? howToPrepare;
  final int? timeToPrepareMin;
}

class RecipeRepository {
  const RecipeRepository(this._db);

  final SqlExecutor _db;

  /// SELECT base. O primeiro parâmetro é o id do usuário que está vendo,
  /// usado para calcular `liked_by_me`.
  static const _select = '''
SELECT r.id, r.user_id, r.title, r.description, r.ingredients,
       r.how_to_prepare, r.time_to_prepare_min, r.image_url,
       r.created_at, r.updated_at,
       u.name AS author_name, u.photo_url AS author_photo_url,
       (SELECT COUNT(*) FROM recipe_likes l WHERE l.recipe_id = r.id)
         AS likes_count,
       EXISTS(SELECT 1 FROM recipe_likes l
              WHERE l.recipe_id = r.id AND l.user_id = ?) AS liked_by_me
FROM recipes r
JOIN users u ON u.id = r.user_id''';

  Future<Recipe?> findById(int id, {required int viewerId}) async {
    final rows = await _db.query('$_select WHERE r.id = ?', [viewerId, id]);
    return rows.isEmpty ? null : Recipe.fromRow(rows.first);
  }

  /// Receitas mais recentes, opcionalmente a partir de [since].
  Future<List<Recipe>> listRecent({
    required int viewerId,
    DateTime? since,
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await _db.query(
      '$_select WHERE (? IS NULL OR r.created_at >= ?) '
      'ORDER BY r.created_at DESC, r.id DESC LIMIT ? OFFSET ?',
      [
        viewerId,
        if (since == null) null else formatDateTime(since),
        if (since == null) null else formatDateTime(since),
        limit,
        offset,
      ],
    );
    return rows.map(Recipe.fromRow).toList();
  }

  Future<List<Recipe>> listByUser(
    int userId, {
    required int viewerId,
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await _db.query(
      '$_select WHERE r.user_id = ? '
      'ORDER BY r.created_at DESC, r.id DESC LIMIT ? OFFSET ?',
      [viewerId, userId, limit, offset],
    );
    return rows.map(Recipe.fromRow).toList();
  }

  /// Busca textual (FULLTEXT em modo booleano, com prefixo em cada termo),
  /// ordenada pelas mais curtidas — o mesmo critério usado com o Algolia.
  Future<List<Recipe>> search(
    String query, {
    required int viewerId,
    int limit = 20,
    int offset = 0,
  }) async {
    final booleanQuery = _toBooleanQuery(query);
    if (booleanQuery.isEmpty) return [];
    final rows = await _db.query(
      '$_select WHERE MATCH(r.title, r.description, r.ingredients) '
      'AGAINST (? IN BOOLEAN MODE) '
      'ORDER BY likes_count DESC, r.created_at DESC LIMIT ? OFFSET ?',
      [viewerId, booleanQuery, limit, offset],
    );
    return rows.map(Recipe.fromRow).toList();
  }

  /// Transforma "bolo de cenoura" em "+bolo* +de* +cenoura*", removendo
  /// operadores do modo booleano digitados pelo usuário.
  static String _toBooleanQuery(String query) {
    return query
        .replaceAll(RegExp(r'[+\-<>()~*"@]'), ' ')
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .take(10)
        .map((term) => '+$term*')
        .join(' ');
  }

  Future<int> create(int userId, RecipeInput input) async {
    final result = await _db.execute(
      'INSERT INTO recipes (user_id, title, description, ingredients, '
      'how_to_prepare, time_to_prepare_min) VALUES (?, ?, ?, ?, ?, ?)',
      [
        userId,
        input.title,
        input.description,
        input.ingredients,
        input.howToPrepare,
        input.timeToPrepareMin,
      ],
    );
    return result.insertId;
  }

  Future<void> update(int id, RecipeInput input) async {
    final fields = <String, Object?>{
      if (input.title != null) 'title': input.title,
      if (input.description != null) 'description': input.description,
      if (input.ingredients != null) 'ingredients': input.ingredients,
      if (input.howToPrepare != null) 'how_to_prepare': input.howToPrepare,
      if (input.timeToPrepareMin != null)
        'time_to_prepare_min': input.timeToPrepareMin,
    };
    if (fields.isEmpty) return;
    await _db.execute(
      'UPDATE recipes SET ${fields.keys.map((c) => '$c = ?').join(', ')} '
      'WHERE id = ?',
      [...fields.values, id],
    );
  }

  Future<void> updateImage(int id, String imageUrl) async {
    await _db.execute(
      'UPDATE recipes SET image_url = ? WHERE id = ?',
      [imageUrl, id],
    );
  }

  Future<void> delete(int id) async {
    await _db.execute('DELETE FROM recipes WHERE id = ?', [id]);
  }

  /// Curtir é idempotente: curtir duas vezes não gera erro.
  Future<void> like(int recipeId, int userId) async {
    await _db.execute(
      'INSERT IGNORE INTO recipe_likes (user_id, recipe_id) VALUES (?, ?)',
      [userId, recipeId],
    );
  }

  Future<void> unlike(int recipeId, int userId) async {
    await _db.execute(
      'DELETE FROM recipe_likes WHERE user_id = ? AND recipe_id = ?',
      [userId, recipeId],
    );
  }
}
