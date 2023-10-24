import 'package:flutter/material.dart';
import 'package:healthy_cook/components/add_recipe_form.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
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
        body: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: AddRecipeForm(),
        ));
  }
}
