// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  FirebaseAuth auth = FirebaseAuth.instance;

  bool _showPassword = false;

  final _formKey = GlobalKey<FormState>();
  final formKeyDialog = GlobalKey<FormState>();

  late String email;
  late String password;
  final lostEmail = TextEditingController();

  void showAlert(String? errorAnswer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          errorAnswer!,
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a senha';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value!.isEmpty) {
      return 'Por favor, insira um email';
    } else if (!regExp.hasMatch(value)) {
      return 'Por favor, insira um email válido.';
    } else {
      return null;
    }
  }

  login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await auth.signInWithEmailAndPassword(email: email, password: password);

        Navigator.of(context).pushReplacementNamed('/home');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' || e.code == 'invalid-email') {
          showAlert('Email ou senha inválidos.');
        } else if (e.code == 'user-disabled') {
          showAlert('Esse usuário corresponde a um email desativado.');
        } else if (e.code == 'user-not-found') {
          showAlert('Usuário não foi encontrado');
        }
      } catch (e) {
        showAlert('Ocorreu um erro desconhecido');
      }
    }
  }

  void sendEmailResetPassword(BuildContext context, String email) async {
    if (formKeyDialog.currentState!.validate()) {
      try {
        await auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF3FA63C),
            content: Text(
              'E-mail de redefinição enviado com sucesso',
            ),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Ocorreu um erro ao enviar o e-mail de redefinição',
            ),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Form(
            key: formKeyDialog,
            child: AlertDialog(
              title: const Text(
                "Esqueceu a senha?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Insira o seu email para redefinir a senha.",
                    style: TextStyle(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: lostEmail,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1C4036))),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Color(0xFF1C4036)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      sendEmailResetPassword(context, lostEmail.text),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C4036)),
                  child: const Text(
                    "Enviar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    lostEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Login',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C4036)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextFormField(
              keyboardType:
                  TextInputType.emailAddress, // aparece o @ no teclado
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email,
                  color: Color(0xFF1C4036),
                ),
                labelText: "Email",
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: _validateEmail,
              onSaved: (value) => email = value!,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.key,
                  color: Color(0xFF1C4036),
                ),
                suffixIcon: IconButton(
                  color: const Color(0xFF1C4036),
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                labelText: "Senha",
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: !_showPassword,
              validator: _validatePassword,
              onSaved: (value) => password = value!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => showForgotPasswordDialog(),
                child: const Text(
                  'Clique aqui',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF3FA63C)),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () => login(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3FA63C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Login",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
