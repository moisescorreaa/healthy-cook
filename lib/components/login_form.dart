import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Login',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextFormField(
              keyboardType:
                  TextInputType.emailAddress, // aparece o @ no teclado
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email),
                labelText: "Email",
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.key),
                labelText: "Senha",
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Login"),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
