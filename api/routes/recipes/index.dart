import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/http/pagination.dart';
import 'package:healthy_cook_api/src/http/recipe_input_parser.dart';
import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/recipe_repository.dart';

/// GET /recipes?q=&since=&limit=&offset=
///   - `q`: busca textual (ordenada por curtidas)
///   - `since`: data ISO 8601; só receitas criadas a partir dela
/// POST /recipes — cria a receita (a imagem vai em PUT /recipes/:id/image)
Future<Response> onRequest(RequestContext context) async {
  final userId = requireUserId(context);
  final recipes = RecipeRepository(context.read<Database>());

  switch (context.request.method) {
    case HttpMethod.get:
      final params = context.request.uri.queryParameters;
      final page = readPagination(context);
      final q = params['q']?.trim() ?? '';
      final DateTime? since;
      if (params['since'] case final value? when value.isNotEmpty) {
        since = DateTime.tryParse(value);
        if (since == null) {
          throw const ApiException.badRequest(
            'Parâmetro "since" deve ser uma data ISO 8601',
          );
        }
      } else {
        since = null;
      }
      final items = q.isNotEmpty
          ? await recipes.search(
              q,
              viewerId: userId,
              limit: page.limit,
              offset: page.offset,
            )
          : await recipes.listRecent(
              viewerId: userId,
              since: since,
              limit: page.limit,
              offset: page.offset,
            );
      return Response.json(
        body: {
          'items': [for (final r in items) r.toJson()],
        },
      );

    case HttpMethod.post:
      final input = parseRecipeInput(
        await readJsonObject(context),
        partial: false,
      );
      final id = await recipes.create(userId, input);
      final recipe = await recipes.findById(id, viewerId: userId);
      return Response.json(
        statusCode: HttpStatus.created,
        body: recipe!.toJson(),
      );

    default:
      throw const ApiException.methodNotAllowed();
  }
}
