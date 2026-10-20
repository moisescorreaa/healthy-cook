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

  void logoutPopUp(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Você tem certeza que deseja sair?',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C4036)),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1C4036))),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Color(0xFF1C4036)),
            ),
          ),
          ElevatedButton(
            onPressed: () => logout(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18592F)),
            child: const Text(
              "Confirmar",
              style: TextStyle(color: Color(0xFFF2F2F2)),
            ),
          ),
        ],
      ),
    );
  }

  void logout(BuildContext context) async {
    try {
      await auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso')),
      );
      Navigator.of(context).pushReplacementNamed('/');
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
          backgroundColor: const Color(0xFF9DF6B0),
          title: const Text(
            'HealthyCook',
            style: TextStyle(fontSize: 20, color: Color(0xFF1C4036)),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            IconButton(
                color: const Color(0xFF1C4036),
                onPressed: () => logoutPopUp(context),
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
                    color: Color(0xFF1C4036),
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
