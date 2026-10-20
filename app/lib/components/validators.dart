final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Por favor, insira um email';
  }
  if (!_emailPattern.hasMatch(value.trim())) {
    return 'Por favor, insira um email válido.';
  }
  return null;
}

/// Mesmas regras da API: de 8 a 72 caracteres.
String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) return 'Por favor, insira uma senha';
  if (value.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
  if (value.length > 72) return 'A senha deve ter no máximo 72 caracteres';
  return null;
}

String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
  return null;
}

String? validateMinutes(String? value) {
  final required = validateRequired(value);
  if (required != null) return required;
  final minutes = int.tryParse(value!.trim());
  if (minutes == null || minutes <= 0) return 'Informe os minutos (ex.: 30)';
  return null;
}
