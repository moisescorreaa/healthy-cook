import 'package:flutter/material.dart';
import 'package:healthy_cook/components/colors_theme_fix.dart';
import 'package:healthy_cook/components/home_cards.dart';

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
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: const Column(
          children: [
            HomeFeed(),
          ],
        ));
  }
}
