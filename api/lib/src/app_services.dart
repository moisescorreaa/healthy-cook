import 'package:healthy_cook_api/src/config/env.dart';
import 'package:healthy_cook_api/src/db/database.dart';
import 'package:healthy_cook_api/src/security/jwt_service.dart';
import 'package:healthy_cook_api/src/security/password_hasher.dart';
import 'package:healthy_cook_api/src/services/auth_service.dart';
import 'package:healthy_cook_api/src/services/image_storage.dart';
import 'package:healthy_cook_api/src/services/mailer.dart';

/// Dependências compartilhadas, criadas uma vez na inicialização do servidor.
class AppServices {
  AppServices({
    required this.db,
    required this.jwt,
    required this.auth,
    required this.images,
    required this.corsAllowedOrigins,
  });

  factory AppServices.fromEnv(Env env) {
    final db = Database.connect(
      host: env.dbHost,
      port: env.dbPort,
      user: env.dbUser,
      password: env.dbPassword,
      database: env.dbName,
    );
    final jwt = JwtService(
      secret: env.jwtSecret,
      accessTokenTtl: env.accessTokenTtl,
    );
    return AppServices(
      db: db,
      jwt: jwt,
      auth: AuthService(
        db: db,
        jwt: jwt,
        hasher: const PasswordHasher(),
        mailer: const ConsoleMailer(),
        publicBaseUrl: env.publicBaseUrl,
        refreshTokenTtl: env.refreshTokenTtl,
      ),
      images: ImageStorage(directory: env.uploadsDir),
      corsAllowedOrigins: env.corsAllowedOrigins,
    );
  }

  final Database db;
  final JwtService jwt;
  final AuthService auth;
  final ImageStorage images;
  final List<String> corsAllowedOrigins;
}
