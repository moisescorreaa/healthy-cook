import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditRecipe extends StatefulWidget {
  final DocumentSnapshot recipeDocument;

  const EditRecipe({Key? key, required this.recipeDocument}) : super(key: key);

  @override
  _EditRecipeState createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  FirebaseAuth auth = FirebaseAuth.instance;

  XFile? image;
  String? _currentImage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _howToPrepareController = TextEditingController();
  final TextEditingController _timeToPrepareController =
      TextEditingController();

  String? validateFields(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => image);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _updateRecipe() async {
    if (_formKey.currentState!.validate()) {
      try {
        String urlImage = _currentImage ?? widget.recipeDocument['urlImage'];

        if (image != null) {
          Reference storageRef = FirebaseStorage.instance.ref().child(
              'images/${auth.currentUser?.uid}/recipes/img-${DateTime.now().toString()}.jpg');
          await storageRef.putFile(File(image!.path));
          urlImage = await storageRef.getDownloadURL();
        }

        await widget.recipeDocument.reference.update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'ingredients': _ingredientsController.text,
          'howToPrepare': _howToPrepareController.text,
          'timeToPrepare': int.parse(_timeToPrepareController.text),
          'urlImage': urlImage,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita atualizada com sucesso!'),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar a receita.'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _currentImage = widget.recipeDocument['urlImage'];
    _titleController.text = widget.recipeDocument['title'];
    _descriptionController.text = widget.recipeDocument['description'];
    _ingredientsController.text = widget.recipeDocument['ingredients'];
    _howToPrepareController.text = widget.recipeDocument['howToPrepare'];
    _timeToPrepareController.text =
        widget.recipeDocument['timeToPrepare'].toString();
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
                          ? Image.file(File(image!.path))
                          : _currentImage != null
                              ? Image.network(_currentImage!)
                              : const Icon(Icons.image),
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
                  validator: (value) => validateFields(value, 'Título'),
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
                  validator: (value) => validateFields(value, 'Descrição'),
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
                  validator: (value) => validateFields(value, 'Ingredientes'),
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
                  validator: (value) =>
                      validateFields(value, 'Tempo de Preparo'),
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
                  validator: (value) =>
                      validateFields(value, 'Modo de Preparo'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateRecipe,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Salvar Alterações',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
