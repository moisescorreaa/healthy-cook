import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFF3FA63C),
      content: Text(message, style: const TextStyle(color: Color(0xFFF2F2F2))),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Color(0xFFF2F2F2))),
    ),
  );
}
