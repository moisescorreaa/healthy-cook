import 'package:flutter/material.dart';
import 'package:healthy_cook/components/search_algolia.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9DF6B0),
          title: const Text(
            'HealthyCook',
            style: TextStyle(fontSize: 20, color: Color(0xFF1C4036)),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), child: SearchAlgolia()));
  }
}
