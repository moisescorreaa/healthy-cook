import 'package:flutter/material.dart';

class RegisterGoogle extends StatefulWidget {
  const RegisterGoogle({super.key});

  @override
  State<RegisterGoogle> createState() => _RegisterGoogleState();
}

class _RegisterGoogleState extends State<RegisterGoogle> {
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
