import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/models/user.dart';

class UserRepository {
  const UserRepository(this._db);

  final SqlExecutor _db;

  static const _columns =
      'id, name, email, password_hash, photo_url, '
      'email_verified_at, created_at';

  Future<User?> findById(int id) async {
    final rows = await _db.query('SELECT $_columns FROM users WHERE id = ?', [
      id,
    ]);
    return rows.isEmpty ? null : User.fromRow(rows.first);
  }

  Future<User?> findByEmail(String email) async {
    final rows = await _db.query(
      'SELECT $_columns FROM users WHERE email = ?',
      [email],
    );
    return rows.isEmpty ? null : User.fromRow(rows.first);
  }

  Future<int> create({
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    final result = await _db.execute(
      'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
      [name, email, passwordHash],
    );
    return result.insertId;
  }

  Future<void> updateProfile(int id, {String? name, String? photoUrl}) async {
    final sets = <String>[];
    final params = <Object?>[];
    if (name != null) {
      sets.add('name = ?');
      params.add(name);
    }
    if (photoUrl != null) {
      sets.add('photo_url = ?');
      params.add(photoUrl);
    }
    if (sets.isEmpty) return;
    await _db.execute(
      'UPDATE users SET ${sets.join(', ')} WHERE id = ?',
      [...params, id],
    );
  }

  Future<void> updatePassword(int id, String passwordHash) async {
    await _db.execute(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [passwordHash, id],
    );
  }

  Future<void> markEmailVerified(int id) async {
    await _db.execute(
      'UPDATE users SET email_verified_at = UTC_TIMESTAMP() '
      'WHERE id = ? AND email_verified_at IS NULL',
      [id],
    );
  }
}
