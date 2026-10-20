import 'package:flutter/material.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/components/image_picking.dart';
import 'package:healthy_cook/components/recipe_image.dart';
import 'package:healthy_cook/components/validators.dart';
import 'package:healthy_cook/data/api_client.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:provider/provider.dart';

/// Edição de uma receita. Ao salvar, devolve a receita atualizada.
class EditRecipe extends StatefulWidget {
  final Recipe recipe;

  const EditRecipe({super.key, required this.recipe});

  @override
  State<EditRecipe> createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  ImageUpload? image;
  bool _saving = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _howToPrepareController = TextEditingController();
  final TextEditingController _timeToPrepareController =
      TextEditingController();

  Future<void> pickImage() async {
    final picked = await pickImageFromGallery();
    if (picked != null) setState(() => image = picked);
  }

  Future<void> _updateRecipe() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = await context.read<RecipeRepository>().update(
            widget.recipe.id,
            RecipeDraft(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              ingredients: _ingredientsController.text.trim(),
              howToPrepare: _howToPrepareController.text.trim(),
              timeToPrepareMin: int.parse(_timeToPrepareController.text.trim()),
            ),
            image: image,
          );
      if (!mounted) return;
      showSuccessSnackBar(context, 'Receita atualizada com sucesso!');
      Navigator.pop(context, updated);
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(
          context, 'Erro ao atualizar a receita. ${e.userMessage}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description;
    _ingredientsController.text = recipe.ingredients;
    _howToPrepareController.text = recipe.howToPrepare;
    _timeToPrepareController.text = recipe.timeToPrepareMin.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _howToPrepareController.dispose();
    _timeToPrepareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: double.maxFinite,
                  height: 200,
                  child: InkWell(
                    onTap: () => pickImage(),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: image != null
                          ? Image.memory(image!.bytes)
                          : RecipeImage(
                              url: widget.recipe.imageUrl,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLength: 150,
                  validator: validateRequired,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ingredientsController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Ingredientes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _timeToPrepareController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Tempo de Preparo (minutos)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: validateMinutes,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _howToPrepareController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Modo de Preparo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _updateRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18592F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Salvar Alterações',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF2F2F2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
