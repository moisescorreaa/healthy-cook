import 'package:flutter/material.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HealthyCook',
          style: TextStyle(fontSize: 20),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
    );
  }
}
