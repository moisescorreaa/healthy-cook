import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_exception.dart';
import 'models/user.dart';
import 'token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Estado da sessão do usuário. Substitui o FirebaseAuth.
class AuthController extends ChangeNotifier {
  AuthController(this._api) {
    _api.onSessionExpired = _handleSessionExpired;
  }

  final ApiClient _api;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? _user;

  /// Usuário logado. Só é `null` quando [status] não é `authenticated`.
  User? get user => _user;

  /// Recupera a sessão salva ao abrir o app.
  Future<void> restoreSession() async {
    if (!await _api.hasSession()) {
      _setUser(null);
      return;
    }
    try {
      await refreshUser();
    } on ApiException {
      // Sem conexão ou sessão inválida: pede login de novo.
      _setUser(null);
    }
  }

  Future<void> login({required String email, required String password}) {
    return _authenticate('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authenticate('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() async {
    final refreshToken = await _api.currentRefreshToken();
    if (refreshToken != null) {
      try {
        await _api.post(
          '/auth/logout',
          body: {'refreshToken': refreshToken},
          auth: false,
        );
      } on ApiException {
        // A sessão local é encerrada mesmo se o servidor não responder.
      }
    }
    await _api.clearTokens();
    _setUser(null);
  }

  Future<void> requestPasswordReset(String email) async {
    await _api.post(
      '/auth/forgot-password',
      body: {'email': email},
      auth: false,
    );
  }

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    await _api.post(
      '/auth/reset-password',
      body: {'token': code, 'password': newPassword},
      auth: false,
    );
  }

  Future<void> resendEmailVerification() async {
    await _api.post('/auth/resend-verification');
  }

  /// Recarrega os dados do usuário (ex.: depois de confirmar o e-mail).
  Future<void> refreshUser() async {
    final json = await _api.get('/users/me') as Map<String, dynamic>;
    _setUser(User.fromJson(json, _api.resolveUrl));
  }

  Future<void> updateName(String name) async {
    final json = await _api.patch('/users/me', body: {'name': name})
        as Map<String, dynamic>;
    _setUser(User.fromJson(json, _api.resolveUrl));
  }

  Future<void> updatePhoto(ImageUpload image) async {
    final json = await _api.uploadImage('/users/me/photo', image)
        as Map<String, dynamic>;
    _setUser(User.fromJson(json, _api.resolveUrl));
  }

  Future<void> _authenticate(String path, Map<String, String> body) async {
    final json =
        await _api.post(path, body: body, auth: false) as Map<String, dynamic>;
    await _api.saveTokens(AuthTokens.fromJson(json));
    _setUser(
      User.fromJson(json['user'] as Map<String, dynamic>, _api.resolveUrl),
    );
  }

  void _handleSessionExpired() => _setUser(null);

  void _setUser(User? user) {
    _user = user;
    _status =
        user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }
}
