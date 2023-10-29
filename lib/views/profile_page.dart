// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_cook/components/edit_profile_form.dart';
import 'package:healthy_cook/components/recipe_list.dart';
import 'package:line_icons/line_icon.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  void logoutPopUp() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Você tem certeza que deseja sair?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => logout(),
            style: ElevatedButton.styleFrom(),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void logout() async {
    try {
      await auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso')),
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao realizar logout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'HealthyCook',
            style: TextStyle(fontSize: 20),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => logoutPopUp(),
                icon: const LineIcon.alternateSignOut())
          ],
        ),
        body: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              EditProfileForm(),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              RecipeList(),
            ],
          ),
        ));
  }
}
