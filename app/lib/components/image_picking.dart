import 'package:flutter/foundation.dart';
import 'package:healthy_cook/data/api_client.dart';
import 'package:image_picker/image_picker.dart';

/// Abre a galeria e devolve a imagem escolhida, já reduzida para envio.
/// Retorna `null` se o usuário cancelar.
Future<ImageUpload?> pickImageFromGallery() async {
  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return ImageUpload(bytes: await file.readAsBytes(), filename: file.name);
  } catch (e) {
    debugPrint('Erro ao escolher imagem: $e');
    return null;
  }
}
