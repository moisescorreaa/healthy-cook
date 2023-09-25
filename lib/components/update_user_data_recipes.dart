import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// EM ANDAMENTO

// Suponha que você tenha uma função para atualizar a URL da foto em um documento Firestore.
Future<void> updatePhotoURLInRecipe(String newPhotoURL) async {
  User? user = FirebaseAuth.instance.currentUser;
  String userId = user?.uid ?? '';
  CollectionReference recipesCollection =
      FirebaseFirestore.instance.collection('recipes');

  // Atualize a URL da foto em todos os documentos relevantes.
  QuerySnapshot recipeDocs =
      await recipesCollection.where('userId', isEqualTo: userId).get();
  for (QueryDocumentSnapshot doc in recipeDocs.docs) {
    await doc.reference.update({'userPhotoURL': newPhotoURL});
  }
}
