import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_exception.dart';
import 'models/recipe.dart';

/// Resultado de curtir ou descurtir uma receita.
typedef LikeStatus = ({int likesCount, bool likedByMe});

/// Acesso às receitas na API. Substitui o Firestore e o Algolia.
///
/// Notifica os ouvintes quando uma receita é criada, editada ou excluída,
/// para que as listas abertas se atualizem (o Firestore fazia isso com os
/// `snapshots()` em tempo real).
class RecipeRepository extends ChangeNotifier {
  RecipeRepository(this._api);

  final ApiClient _api;

  /// Receitas mais recentes, opcionalmente a partir de [since].
  Future<List<Recipe>> feed({DateTime? since, int limit = 50}) {
    return _list('/recipes', {
      if (since != null) 'since': since.toUtc().toIso8601String(),
      'limit': '$limit',
    });
  }

  /// Busca por texto, com as receitas mais curtidas primeiro.
  Future<List<Recipe>> search(String query, {int limit = 50}) {
    return _list('/recipes', {'q': query, 'limit': '$limit'});
  }

  Future<List<Recipe>> mine({int limit = 50}) {
    return _list('/users/me/recipes', {'limit': '$limit'});
  }

  Future<Recipe> get(int id) async {
    return _parse(await _api.get('/recipes/$id'));
  }

  /// Cria a receita e envia a imagem. Se o envio da imagem falhar, a receita
  /// é removida para não ficar publicada pela metade.
  Future<Recipe> create(RecipeDraft draft, ImageUpload image) async {
    final created = _parse(await _api.post('/recipes', body: draft.toJson()));
    final Recipe recipe;
    try {
      recipe =
          _parse(await _api.uploadImage('/recipes/${created.id}/image', image));
    } on ApiException {
      await _api.delete('/recipes/${created.id}').catchError((_) => null);
      rethrow;
    }
    notifyListeners();
    return recipe;
  }

  Future<Recipe> update(int id, RecipeDraft draft, {ImageUpload? image}) async {
    var recipe = _parse(await _api.patch('/recipes/$id', body: draft.toJson()));
    if (image != null) {
      recipe = _parse(await _api.uploadImage('/recipes/$id/image', image));
    }
    notifyListeners();
    return recipe;
  }

  Future<void> delete(int id) async {
    await _api.delete('/recipes/$id');
    notifyListeners();
  }

  /// Pede que as listas abertas recarreguem (ex.: o autor mudou o nome ou a
  /// foto, que aparecem em todas as receitas dele).
  void refreshLists() => notifyListeners();

  Future<LikeStatus> setLiked(int id, {required bool liked}) async {
    final path = '/recipes/$id/like';
    final json = (liked ? await _api.put(path) : await _api.delete(path))
        as Map<String, dynamic>;
    return (
      likesCount: json['likesCount'] as int,
      likedByMe: json['likedByMe'] as bool,
    );
  }

  Future<List<Recipe>> _list(String path, Map<String, String> query) async {
    final json = await _api.get(path, query: query) as Map<String, dynamic>;
    return (json['items'] as List).map(_parse).toList();
  }

  Recipe _parse(dynamic json) =>
      Recipe.fromJson(json as Map<String, dynamic>, _api.resolveUrl);
}
