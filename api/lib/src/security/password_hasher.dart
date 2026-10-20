import 'dart:isolate';

import 'package:bcrypt/bcrypt.dart';

/// Hash de senhas com bcrypt. Roda em outro isolate para não travar o servidor.
class PasswordHasher {
  const PasswordHasher({this.logRounds = 12});

  final int logRounds;

  Future<String> hash(String password) {
    final rounds = logRounds;
    return Isolate.run(
      () => BCrypt.hashpw(password, BCrypt.gensalt(logRounds: rounds)),
    );
  }

  Future<bool> verify(String password, String hash) {
    return Isolate.run(() => BCrypt.checkpw(password, hash));
  }
}
