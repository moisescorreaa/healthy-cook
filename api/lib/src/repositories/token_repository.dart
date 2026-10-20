import 'package:healthy_cook_api/src/db/database.dart';

enum EmailTokenType { verify, reset }

/// Refresh tokens e tokens enviados por e-mail. Só os hashes são salvos.
class TokenRepository {
  const TokenRepository(this._db);

  final SqlExecutor _db;

  Future<void> createRefreshToken({
    required int userId,
    required String tokenHash,
    required DateTime expiresAt,
  }) async {
    await _db.execute(
      'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) '
      'VALUES (?, ?, ?)',
      [userId, tokenHash, formatDateTime(expiresAt)],
    );
  }

  /// Revoga um refresh token válido e retorna o dono, ou `null` se o token
  /// não existir, já tiver sido usado ou estiver expirado.
  Future<int?> consumeRefreshToken(String tokenHash) async {
    final rows = await _db.query(
      'SELECT id, user_id FROM refresh_tokens '
      'WHERE token_hash = ? AND revoked_at IS NULL '
      'AND expires_at > UTC_TIMESTAMP() FOR UPDATE',
      [tokenHash],
    );
    if (rows.isEmpty) return null;
    await _db.execute(
      'UPDATE refresh_tokens SET revoked_at = UTC_TIMESTAMP() WHERE id = ?',
      [rows.first.intValue('id')],
    );
    return rows.first.intValue('user_id');
  }

  /// Retorna o dono de um refresh token já revogado (indício de reuso).
  Future<int?> findRevokedRefreshTokenOwner(String tokenHash) async {
    final rows = await _db.query(
      'SELECT user_id FROM refresh_tokens '
      'WHERE token_hash = ? AND revoked_at IS NOT NULL',
      [tokenHash],
    );
    return rows.isEmpty ? null : rows.first.intValue('user_id');
  }

  Future<void> revokeRefreshToken(String tokenHash) async {
    await _db.execute(
      'UPDATE refresh_tokens SET revoked_at = UTC_TIMESTAMP() '
      'WHERE token_hash = ? AND revoked_at IS NULL',
      [tokenHash],
    );
  }

  Future<void> revokeAllRefreshTokens(int userId) async {
    await _db.execute(
      'UPDATE refresh_tokens SET revoked_at = UTC_TIMESTAMP() '
      'WHERE user_id = ? AND revoked_at IS NULL',
      [userId],
    );
  }

  /// Cria um token de e-mail, invalidando os anteriores do mesmo tipo.
  Future<void> createEmailToken({
    required int userId,
    required EmailTokenType type,
    required String tokenHash,
    required DateTime expiresAt,
  }) async {
    await _db.execute(
      'UPDATE email_tokens SET used_at = UTC_TIMESTAMP() '
      'WHERE user_id = ? AND type = ? AND used_at IS NULL',
      [userId, type.name],
    );
    await _db.execute(
      'INSERT INTO email_tokens (user_id, type, token_hash, expires_at) '
      'VALUES (?, ?, ?, ?)',
      [userId, type.name, tokenHash, formatDateTime(expiresAt)],
    );
  }

  /// Marca o token como usado e retorna o dono, ou `null` se inválido.
  Future<int?> consumeEmailToken(EmailTokenType type, String tokenHash) async {
    final rows = await _db.query(
      'SELECT id, user_id FROM email_tokens '
      'WHERE token_hash = ? AND type = ? AND used_at IS NULL '
      'AND expires_at > UTC_TIMESTAMP() FOR UPDATE',
      [tokenHash, type.name],
    );
    if (rows.isEmpty) return null;
    await _db.execute(
      'UPDATE email_tokens SET used_at = UTC_TIMESTAMP() WHERE id = ?',
      [rows.first.intValue('id')],
    );
    return rows.first.intValue('user_id');
  }
}
