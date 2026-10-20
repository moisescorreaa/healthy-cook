import 'package:flutter/foundation.dart';

/// Endereço da API.
///
/// Pode ser definido na execução:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080`
///
/// Sem a definição, usa a API local: no emulador Android o computador fica em
/// `10.0.2.2`; nas demais plataformas, em `localhost`.
Uri apiBaseUrl() {
  const fromEnvironment = String.fromEnvironment('API_BASE_URL');
  if (fromEnvironment.isNotEmpty) return Uri.parse(fromEnvironment);
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return Uri.parse('http://10.0.2.2:8080');
  }
  return Uri.parse('http://localhost:8080');
}
