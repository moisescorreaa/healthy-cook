import 'package:flutter/material.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/components/image_picking.dart';
import 'package:healthy_cook/components/validators.dart';
import 'package:healthy_cook/data/api_client.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/models/recipe.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class AddRecipeForm extends StatefulWidget {
  const AddRecipeForm({super.key});

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  final _formKey = GlobalKey<FormState>();

  ImageUpload? image;
  bool _saving = false;

  TextEditingController ingredientsController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeToPrepareController = TextEditingController();
  TextEditingController howToPrepareController = TextEditingController();

  Future<void> pickImage() async {
    final picked = await pickImageFromGallery();
    if (picked != null) setState(() => image = picked);
  }

  Future<void> saveRecipe() async {
    if (_saving) return;
    final valid = _formKey.currentState!.validate();
    if (!valid || image == null) {
      showErrorSnackBar(
        context,
        image == null && valid
            ? 'Escolha uma imagem para a receita'
            : 'Preencha todos os campos obrigatórios',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<RecipeRepository>().create(
            RecipeDraft(
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
              ingredients: ingredientsController.text.trim(),
              howToPrepare: howToPrepareController.text.trim(),
              timeToPrepareMin: int.parse(timeToPrepareController.text.trim()),
            ),
            image!,
          );
      if (!mounted) return;
      setState(() {
        image = null;
        titleController.clear();
        descriptionController.clear();
        timeToPrepareController.clear();
        howToPrepareController.clear();
        ingredientsController.clear();
      });
      showSuccessSnackBar(context, 'Receita postada com sucesso!');
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        'Ocorreu um erro ao postar a receita. ${e.userMessage}',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    ingredientsController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    timeToPrepareController.dispose();
    howToPrepareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => pickImage(),
                child: image != null
                    ? Image.memory(image!.bytes)
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 200,
                        child: const Center(
                          child: LineIcon(
                            LineIcons.image,
                            size: 100,
                            color: Color(0xFF1C4036),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLength: 150,
                validator: validateRequired,
                controller: titleController,
              ),
              const SizedBox(height: 10),
              TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Descrição",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: validateRequired,
                  controller: descriptionController),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Ingredientes",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: validateRequired,
                controller: ingredientsController,
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Tempo de preparo (em minutos)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: validateMinutes,
                controller: timeToPrepareController,
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Modo de Preparo",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: validateRequired,
                controller: howToPrepareController,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: _saving ? null : saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C4036),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF2F2F2),
                          ),
                        )
                      : const Text(
                          "Salvar",
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
    );
  }
}
