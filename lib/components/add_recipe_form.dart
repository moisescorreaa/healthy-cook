import 'package:flutter/material.dart';
import 'package:healthy_cook/components/colors_theme_fix.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: LineIcon(
                  LineIcons.image,
                  color: foregroundColor,
                  size: 200,
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: "Título",
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.text,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Descrição",
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.text,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Ingredientes",
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.number,
            maxLines: null,
            decoration: InputDecoration(
              labelText: "Tempo de preparo (em minutos)",
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.text,
            maxLines: null,
            decoration: InputDecoration(
              labelText: "Modo de Preparo",
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Salvar"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
