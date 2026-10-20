import 'package:flutter/material.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/components/validators.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();
  final formKeyDialog = GlobalKey<FormState>();

  late String email;
  late String password;
  final lostEmail = TextEditingController();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a senha';
    }
    return null;
  }

  Future<void> login() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await context
          .read<AuthController>()
          .login(email: email.trim(), password: password);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        e.code == 'invalid_credentials'
            ? 'Email ou senha inválidos.'
            : e.userMessage,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> sendEmailResetPassword(BuildContext dialogContext) async {
    if (!formKeyDialog.currentState!.validate()) return;
    final email = lostEmail.text.trim();
    try {
      await context.read<AuthController>().requestPasswordReset(email);
      if (!mounted) return;
      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
      showSuccessSnackBar(
        context,
        'Se o e-mail estiver cadastrado, enviamos um código de redefinição',
      );
      Navigator.of(context).pushNamed('/reset-password', arguments: email);
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.userMessage);
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
                    validator: validateEmail,
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
                  onPressed: () => sendEmailResetPassword(context),
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
              validator: validateEmail,
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
              onPressed: _loading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3FA63C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
