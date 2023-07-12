import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
