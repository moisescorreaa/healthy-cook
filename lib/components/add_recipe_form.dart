import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class AddRecipeForm extends StatefulWidget {
  const AddRecipeForm({super.key});

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  XFile? image;
  String? title;
  String? description;
  String? ingredients;
  int? timeToPrepare;
  String? howToPrepare;

  TextEditingController ingredientsController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeToPrepareController = TextEditingController();
  TextEditingController howToPrepareController = TextEditingController();

  String? validateFields(String? value) {
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

  Future<void> saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (image != null) {
        try {
          String refImage =
              'images/${auth.currentUser?.uid}/recipes/img-${DateTime.now().toString()}.jpg';
          Reference storageRef = FirebaseStorage.instance.ref().child(refImage);
          await storageRef.putFile(File(image!.path));

          String urlImage = await storageRef.getDownloadURL();

          CollectionReference refRecipes = db.collection('recipes');
          await refRecipes.add({
            'nameUser': auth.currentUser?.displayName,
            'photoUser': auth.currentUser?.photoURL,
            'uidUser': auth.currentUser?.uid,
            'refImage': refImage,
            'urlImage': urlImage,
            'title': title,
            'description': description,
            'ingredients': ingredients,
            'timeToPrepare': timeToPrepare,
            'howToPrepare': howToPrepare,
            'likes': [],
            'dateTime': DateTime.now(),
          });

          setState(() {
            image = null;
            title = '';
            description = '';
            ingredients = '';
            timeToPrepare = null;
            howToPrepare = '';
            titleController.clear();
            descriptionController.clear();
            timeToPrepareController.clear();
            howToPrepareController.clear();
            ingredientsController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receita postada com sucesso!'),
            ),
          );
        } catch (e) {
          // Lida com erros, se houver
          if (kDebugMode) {
            print('Erro ao salvar a receita: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocorreu um erro ao postar a receita'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insira uma imagem para a receita'),
          ),
        );
      }
    }
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
                    ? Image.file(File(image!.path))
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 200,
                        child: const Center(
                          child: LineIcon(
                            LineIcons.image,
                            size: 100,
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
                validator: validateFields,
                onChanged: (value) => title = value,
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
                  validator: validateFields,
                  onChanged: (value) => description = value,
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
                validator: validateFields,
                onChanged: (value) => ingredients = value,
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
                validator: validateFields,
                onChanged: (value) => timeToPrepare = int.tryParse(value),
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
                validator: validateFields,
                onChanged: (value) => howToPrepare = value,
                controller: howToPrepareController,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () => saveRecipe(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Salvar",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
