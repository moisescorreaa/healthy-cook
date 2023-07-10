import 'package:flutter/material.dart';
import 'package:healthy_cook/components/login_google.dart';
import 'package:healthy_cook/components/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset('assets/images/logotipo.png'),
                    ),
                  ),
                ],
              ),
              RegisterForm(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já tem uma conta?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    child: const Text(
                      ' Faça login aqui',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                child: Text(
                  "ou",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              LoginGoogle(),
            ],
          ),
        ),
      ),
    );
  }
}
