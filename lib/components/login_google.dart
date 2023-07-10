import 'package:flutter/material.dart';

class LoginGoogle extends StatefulWidget {
  const LoginGoogle({super.key});

  @override
  State<LoginGoogle> createState() => _LoginGoogleState();
}

class _LoginGoogleState extends State<LoginGoogle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          child: IconButton(
              onPressed: () {}, icon: Image.asset('assets/images/google.png')),
        ),
      ],
    );
  }
}
