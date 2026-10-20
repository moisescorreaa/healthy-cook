import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Salva imagens enviadas pelo app no disco e as expõe em `/uploads`.
class ImageStorage {
  ImageStorage({required this.directory, required this.publicBaseUrl});

  static const maxBytes = 5 * 1024 * 1024;

  static const _extensions = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
  };

  final String directory;
  final String publicBaseUrl;
  final _uuid = const Uuid();

  String get _baseUrl => '$publicBaseUrl/uploads/';

  /// Lê o campo `image` de uma requisição multipart, salva e retorna a URL.
  Future<String> save(Request request, {required String folder}) async {
    final contentType = request.headers['content-type'] ?? '';
    if (!contentType.startsWith('multipart/form-data')) {
      throw const ApiException.badRequest(
        'Envie a imagem como multipart/form-data no campo "image"',
      );
    }
    final length = int.tryParse(request.headers['content-length'] ?? '');
    if (length != null && length > maxBytes + 64 * 1024) {
      throw const ApiException(413, 'too_large', 'Imagem maior que 5 MB');
    }

    final form = await request.formData();
    final file = form.files['image'];
    if (file == null) {
      throw const ApiException.badRequest('Campo "image" ausente');
    }
    final extension = _extensions[file.contentType.mimeType];
    if (extension == null) {
      throw const ApiException.badRequest('Use uma imagem JPEG, PNG ou WebP');
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) {
      throw const ApiException(413, 'too_large', 'Imagem maior que 5 MB');
    }
    if (!_matchesSignature(bytes, extension)) {
      throw const ApiException.badRequest('Arquivo de imagem inválido');
    }

    final relativePath = '$folder/${_uuid.v4()}.$extension';
    final target = File(p.join(directory, relativePath));
    await target.parent.create(recursive: true);
    await target.writeAsBytes(bytes, flush: true);
    return '$_baseUrl$relativePath';
  }

  /// Remove uma imagem salva por esta API. URLs externas são ignoradas.
  Future<void> deleteByUrl(String? url) async {
    if (url == null || !url.startsWith(_baseUrl)) return;
    final relativePath = url.substring(_baseUrl.length);
    final file = File(p.normalize(p.join(directory, relativePath)));
    if (!p.isWithin(p.normalize(directory), file.path)) return;
    if (file.existsSync()) await file.delete();
  }

  /// Confere os "magic bytes" para não confiar só no content-type enviado.
  static bool _matchesSignature(List<int> bytes, String extension) {
    bool startsWith(List<int> signature, [int offset = 0]) {
      if (bytes.length < offset + signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (bytes[offset + i] != signature[i]) return false;
      }
      return true;
    }

    return switch (extension) {
      'jpg' => startsWith([0xFF, 0xD8, 0xFF]),
      'png' => startsWith([0x89, 0x50, 0x4E, 0x47]),
      'webp' =>
        startsWith([0x52, 0x49, 0x46, 0x46]) &&
            startsWith([0x57, 0x45, 0x42, 0x50], 8),
      _ => false,
    };
  }
}
