import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  bool? verified;
  String? username;
  String? urlImage;
  XFile? image;

  String? newUsername;

  @override
  void initState() {
    super.initState();
    updateUserData();
    checkUser();
  }

  void updateUserData() {
    setState(() {
      username = auth.currentUser?.displayName;
      urlImage = auth.currentUser?.photoURL;
    });
  }

  checkUser() {
    if (auth.currentUser?.emailVerified == true) {
      setState(() => verified = true);
    } else {
      setState(() => verified = false);
    }
  }

  changeUserData() async {
    try {
      bool changedData = false;

      if (image != null) {
        String refImage =
            'images/${auth.currentUser?.uid}/profile/img-${DateTime.now().toString()}.jpg';
        Reference storageRef = storage.ref().child(refImage);
        await storageRef.putFile(File(image!.path));
        urlImage = await storageRef.getDownloadURL();
        setState(() => urlImage);

        auth.currentUser?.updatePhotoURL(urlImage);
        changedData = true;
      }

      if (newUsername != null && newUsername!.isNotEmpty) {
        auth.currentUser?.updateDisplayName(newUsername);
        setState(() => username = newUsername);
        changedData = true;
      }

      if (changedData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados alterados com sucesso'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma alteração realizada'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro ao alterar os dados'),
          duration: Duration(seconds: 3),
        ),
      );
    }
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

  void changaDataProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text(
            "Editar Perfil",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => pickImage().then((_) {
                    setState(() =>
                        {}); // Atualiza a interface do pop-up após selecionar a imagem
                  }),
                  child: Container(
                    width: double.maxFinite,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: image != null
                        ? Image.file(File(image!.path))
                        : Container(
                            width: double.maxFinite,
                            height: 180,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.insert_photo_outlined,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Inserir Imagem',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      newUsername = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Novo nome de perfil",
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () => changeUserData(),
                      child: const Text("Enviar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 50,
          backgroundImage: NetworkImage(urlImage!),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  username!,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            verified == true
                ? const Icon(
                    Icons.verified_outlined,
                  )
                : const SizedBox.shrink()
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => changaDataProfile(context),
          child: const Text(
            'Editar perfil',
          ),
        ),
      ],
    );
  }
}
