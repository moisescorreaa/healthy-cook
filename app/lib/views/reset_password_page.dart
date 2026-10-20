import 'package:flutter/material.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/components/validators.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:provider/provider.dart';

/// Redefinição de senha com o código enviado por e-mail.
///
/// Recebe opcionalmente o e-mail como argumento da rota, só para exibição.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthController>().resetPassword(
            code: _codeController.text.trim(),
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      showSuccessSnackBar(context, 'Senha alterada! Faça login novamente.');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.userMessage);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF1C4036)),
      suffixIcon: suffix,
      labelText: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9DF6B0),
        title: const Text(
          'Redefinir senha',
          style: TextStyle(color: Color(0xFF1C4036)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    email == null
                        ? 'Informe o código que enviamos para o seu e-mail '
                            'e escolha uma nova senha.'
                        : 'Informe o código que enviamos para $email '
                            'e escolha uma nova senha.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF1C4036)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _codeController,
                    decoration: _decoration('Código', Icons.pin),
                    validator: validateRequired,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: _decoration(
                      'Nova senha',
                      Icons.key,
                      suffix: IconButton(
                        color: const Color(0xFF1C4036),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    validator: validateNewPassword,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FA63C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Salvar nova senha',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
