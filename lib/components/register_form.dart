import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Cadastro',
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
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                labelText: 'Nome do usuário',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: true,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              TextButton(
                  onPressed: () {},
                  child: Text(
                    'Termos de uso',
                  ))
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Cadastrar"),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
