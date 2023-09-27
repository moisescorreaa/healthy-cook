import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? user = FirebaseAuth.instance.currentUser;
String uidUser = user?.uid ?? '';
CollectionReference recipesCollection =
    FirebaseFirestore.instance.collection('recipes');

updatePhotoUserURLInRecipe(String? newPhotoURL) async {
  QuerySnapshot recipeDocs =
      await recipesCollection.where('uidUser', isEqualTo: uidUser).get();
  for (QueryDocumentSnapshot doc in recipeDocs.docs) {
    await doc.reference.update({'photoUser': newPhotoURL});
  }
}

updateUsernameUserInRecipe(String? newUsername) async {
  QuerySnapshot recipeDocs =
      await recipesCollection.where('uidUser', isEqualTo: uidUser).get();
  for (QueryDocumentSnapshot doc in recipeDocs.docs) {
    await doc.reference.update({'nameUser': newUsername});
  }
}
