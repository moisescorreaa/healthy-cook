import 'package:flutter/material.dart';
import 'package:healthy_cook/components/colors_theme_fix.dart';

class AddRecipeForm extends StatefulWidget {
  const AddRecipeForm({super.key});

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Upload Image',
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
