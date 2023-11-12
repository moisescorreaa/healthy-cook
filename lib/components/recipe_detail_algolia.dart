import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDetailAlgolia extends StatefulWidget {
  final String recipeDocumentId;

  RecipeDetailAlgolia({required this.recipeDocumentId});

  @override
  _RecipeDetailAlgoliaState createState() => _RecipeDetailAlgoliaState();
}

class _RecipeDetailAlgoliaState extends State<RecipeDetailAlgolia> {
  late Stream<DocumentSnapshot> _recipeStream;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _recipeStream =
        db.collection('recipes').doc(widget.recipeDocumentId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9DF6B0),
        title: const Text(
          'Detalhes da Receita',
          style: TextStyle(color: Color(0xFF1C4036)),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _recipeStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final recipeData = snapshot.data!;
            final urlImage = recipeData['urlImage'];
            final title = recipeData['title'];
            final description = recipeData['description'];
            final ingredients = recipeData['ingredients'];
            final timeToPrepare = recipeData['timeToPrepare'];
            final howToPrepare = recipeData['howToPrepare'];
            final photoUser = recipeData['photoUser'];
            final nameUser = recipeData['nameUser'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(urlImage),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ingredientes:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ingredients,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Modo de Preparo:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          howToPrepare,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tempo de Preparo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${timeToPrepare.toString()} minutos",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Postado por:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(photoUser),
                              radius: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              nameUser,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar os detalhes da receita.'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
