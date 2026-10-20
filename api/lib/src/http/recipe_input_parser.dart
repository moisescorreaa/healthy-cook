import 'package:healthy_cook_api/src/http/request_utils.dart';
import 'package:healthy_cook_api/src/repositories/recipe_repository.dart';

/// Valida o corpo de criação (todos os campos) ou edição (campos enviados).
RecipeInput parseRecipeInput(
  Map<String, dynamic> data, {
  required bool partial,
}) {
  final v = Validator(data);
  bool req(String field) => !partial || v.has(field);

  final input = RecipeInput(
    title: req('title') ? v.string('title', maxLength: 150) : null,
    description: req('description')
        ? v.string('description', maxLength: 5000)
        : null,
    ingredients: req('ingredients')
        ? v.string('ingredients', maxLength: 10000)
        : null,
    howToPrepare: req('howToPrepare')
        ? v.string('howToPrepare', maxLength: 20000)
        : null,
    timeToPrepareMin: req('timeToPrepareMin')
        ? v.positiveInt('timeToPrepareMin', max: 10000)
        : null,
  );
  v.check();
  return input;
}
