import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_cook/components/recipe_detail.dart';

class HomeFeed extends StatefulWidget {
  final DateTime? date;

  const HomeFeed({super.key, required this.date});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  void updateLikes(DocumentSnapshot document, List<String> likes) {
    db.collection('recipes').doc(document.id).update({'likes': likes});
  }

  void navigateToRecipeDetail(DocumentSnapshot documentSnapshot) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RecipeDetail(
                recipeDocument: documentSnapshot,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser?.uid;
    final startDate = widget.date;
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('recipes')
            .where('dateTime', isGreaterThanOrEqualTo: startDate)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot> recipes = snapshot.data!.docs;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final document = recipes[index];
                final photoUser = document['photoUser'];
                final nameUser = document['nameUser'];
                final urlImage = document['urlImage'];
                final title = document['title'];
                final description = document['description'];

                List<String> likes = [];
                if (document['likes'] != null) {
                  likes = List<String>.from(document['likes']);
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(photoUser),
                              maxRadius: 10,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              nameUser,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: ClipRRect(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(urlImage),
                              ),
                            ),
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, top: 8, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            StreamBuilder<DocumentSnapshot>(
                              stream: db
                                  .collection('recipes')
                                  .doc(document.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final likes =
                                      (snapshot.data!['likes'] as List<dynamic>)
                                          .map((uid) => uid.toString())
                                          .toList();
                                  final isLiked = likes.contains(uid);

                                  return IconButton(
                                    color: Colors.red,
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (isLiked) {
                                          likes.remove(uid);
                                        } else {
                                          likes.add(uid!);
                                        }
                                        updateLikes(document, likes);
                                      });
                                    },
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                            Text(
                              '${likes.length.toString()} ${likes.length == 1 ? "curtida" : "curtidas"}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.red),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: TextButton(
                                onPressed: () =>
                                    navigateToRecipeDetail(document),
                                child: const Text(
                                  'Ver receita',
                                  style: TextStyle(
                                    color: Color(0xFF1D7332),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
