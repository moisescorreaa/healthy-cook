import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/http/api_exception.dart';
import 'package:healthy_cook_api/src/models/user.dart';
import 'package:healthy_cook_api/src/repositories/token_repository.dart';
import 'package:healthy_cook_api/src/repositories/user_repository.dart';
import 'package:healthy_cook_api/src/security/jwt_service.dart';
import 'package:healthy_cook_api/src/security/password_hasher.dart';
import 'package:healthy_cook_api/src/security/secure_token.dart';
import 'package:healthy_cook_api/src/services/mailer.dart';

/// Par de tokens entregue ao app após login, cadastro ou renovação.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final Duration expiresIn;

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': 'Bearer',
    'expiresIn': expiresIn.inSeconds,
  };
}

class AuthResult {
  const AuthResult(this.user, this.tokens);

  final User user;
  final AuthTokens tokens;

  Map<String, Object?> toJson() => {'user': user.toJson(), ...tokens.toJson()};
}

class AuthService {
  AuthService({
    required Database db,
    required JwtService jwt,
    required PasswordHasher hasher,
    required Mailer mailer,
    required String publicBaseUrl,
    required Duration refreshTokenTtl,
  }) : _db = db,
       _jwt = jwt,
       _hasher = hasher,
       _mailer = mailer,
       _publicBaseUrl = publicBaseUrl,
       _refreshTokenTtl = refreshTokenTtl;

  static const _verifyTokenTtl = Duration(hours: 24);
  static const _resetTokenTtl = Duration(hours: 1);

  final Database _db;
  final JwtService _jwt;
  final PasswordHasher _hasher;
  final Mailer _mailer;
  final String _publicBaseUrl;
  final Duration _refreshTokenTtl;

  /// Hash usado quando o e-mail não existe, para que o tempo de resposta do
  /// login não revele quais e-mails estão cadastrados.
  late final Future<String> _dummyHash = _hasher.hash('senha-inexistente');

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = UserRepository(_db);
    if (await users.findByEmail(email) != null) {
      throw const ApiException.conflict(
        'email_in_use',
        'Este e-mail já está cadastrado',
      );
    }
    final passwordHash = await _hasher.hash(password);
    final int userId;
    try {
      userId = await users.create(
        name: name,
        email: email,
        passwordHash: passwordHash,
      );
    } on Exception catch (e) {
      // Corrida entre dois cadastros com o mesmo e-mail.
      if ('$e'.contains('Duplicate entry')) {
        throw const ApiException.conflict(
          'email_in_use',
          'Este e-mail já está cadastrado',
        );
      }
      rethrow;
    }
    final user = (await users.findById(userId))!;
    await sendEmailVerification(user);
    return AuthResult(user, await _issueTokens(user.id));
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final user = await UserRepository(_db).findByEmail(email);
    final valid = await _hasher.verify(
      password,
      user?.passwordHash ?? await _dummyHash,
    );
    if (user == null || !valid) {
      throw const ApiException(
        401,
        'invalid_credentials',
        'E-mail ou senha incorretos',
      );
    }
    return AuthResult(user, await _issueTokens(user.id));
  }

  /// Troca um refresh token por um novo par (rotação). Se um token já usado
  /// for apresentado de novo, todas as sessões do usuário são encerradas.
  Future<AuthResult> refresh(String refreshToken) async {
    final tokenHash = hashToken(refreshToken);
    final userId = await _db.transaction(
      (tx) => TokenRepository(tx).consumeRefreshToken(tokenHash),
    );
    if (userId == null) {
      final tokens = TokenRepository(_db);
      final reusedBy = await tokens.findRevokedRefreshTokenOwner(tokenHash);
      if (reusedBy != null) await tokens.revokeAllRefreshTokens(reusedBy);
      throw const ApiException(
        401,
        'invalid_refresh_token',
        'Sessão expirada, faça login novamente',
      );
    }
    final user = await UserRepository(_db).findById(userId);
    if (user == null) throw const ApiException.unauthorized();
    return AuthResult(user, await _issueTokens(user.id));
  }

  Future<void> logout(String refreshToken) {
    return TokenRepository(_db).revokeRefreshToken(hashToken(refreshToken));
  }

  Future<void> logoutAll(int userId) {
    return TokenRepository(_db).revokeAllRefreshTokens(userId);
  }

  Future<void> sendEmailVerification(User user) async {
    if (user.emailVerified) return;
    final token = generateSecureToken();
    await TokenRepository(_db).createEmailToken(
      userId: user.id,
      type: EmailTokenType.verify,
      tokenHash: hashToken(token),
      expiresAt: DateTime.now().add(_verifyTokenTtl),
    );
    final link = '$_publicBaseUrl/auth/verify-email?token=$token';
    await _mailer.send(
      to: user.email,
      subject: 'Confirme seu e-mail no Healthy Cook',
      body:
          'Olá, ${user.name}!\n\n'
          'Confirme seu e-mail acessando o link abaixo:\n$link\n\n'
          'O link expira em 24 horas.',
    );
  }

  /// Retorna `false` se o token for inválido ou expirado.
  Future<bool> verifyEmail(String token) async {
    final userId = await _db.transaction((tx) async {
      final userId = await TokenRepository(
        tx,
      ).consumeEmailToken(EmailTokenType.verify, hashToken(token));
      if (userId != null) await UserRepository(tx).markEmailVerified(userId);
      return userId;
    });
    return userId != null;
  }

  /// Sempre conclui sem erro, para não revelar se o e-mail está cadastrado.
  Future<void> requestPasswordReset(String email) async {
    final user = await UserRepository(_db).findByEmail(email);
    if (user == null) return;
    final token = generateSecureToken();
    await TokenRepository(_db).createEmailToken(
      userId: user.id,
      type: EmailTokenType.reset,
      tokenHash: hashToken(token),
      expiresAt: DateTime.now().add(_resetTokenTtl),
    );
    await _mailer.send(
      to: user.email,
      subject: 'Redefinição de senha do Healthy Cook',
      body:
          'Olá, ${user.name}!\n\n'
          'Use o código abaixo no app para criar uma nova senha:\n$token\n\n'
          'O código expira em 1 hora. Se não foi você, ignore este e-mail.',
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final passwordHash = await _hasher.hash(newPassword);
    final userId = await _db.transaction((tx) async {
      final userId = await TokenRepository(
        tx,
      ).consumeEmailToken(EmailTokenType.reset, hashToken(token));
      if (userId == null) return null;
      await UserRepository(tx).updatePassword(userId, passwordHash);
      // Quem tinha a senha antiga perde as sessões abertas.
      await TokenRepository(tx).revokeAllRefreshTokens(userId);
      return userId;
    });
    if (userId == null) {
      throw const ApiException.badRequest('Código inválido ou expirado');
    }
  }

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final users = UserRepository(_db);
    final user = await users.findById(userId);
    if (user == null) throw const ApiException.unauthorized();
    if (!await _hasher.verify(currentPassword, user.passwordHash)) {
      throw const ApiException.badRequest(
        'Dados inválidos',
        details: {'currentPassword': 'Senha atual incorreta'},
      );
    }
    await users.updatePassword(userId, await _hasher.hash(newPassword));
  }

  Future<AuthTokens> _issueTokens(int userId) async {
    final refreshToken = generateSecureToken();
    await TokenRepository(_db).createRefreshToken(
      userId: userId,
      tokenHash: hashToken(refreshToken),
      expiresAt: DateTime.now().add(_refreshTokenTtl),
    );
    return AuthTokens(
      accessToken: _jwt.issueAccessToken(userId),
      refreshToken: refreshToken,
      expiresIn: _jwt.accessTokenTtl,
    );
  }
}
