import 'package:flutter/material.dart';
import 'package:healthy_cook/components/edit_profile_form.dart';
import 'package:healthy_cook/components/recipe_list.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:line_icons/line_icon.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            onPressed: () {
              Navigator.of(context).pop();
              logout();
            },
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

  /// O App volta para a tela inicial quando a sessão é encerrada.
  Future<void> logout() async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AuthController>().logout();
    messenger.showSnackBar(
      const SnackBar(content: Text('Logout realizado com sucesso')),
    );
  }

  Future<void> _refresh() async {
    try {
      await context.read<AuthController>().refreshUser();
    } on ApiException {
      // Mantém os dados atuais; a lista de receitas mostra o erro.
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
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: const SingleChildScrollView(
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
            )));
  }
}
