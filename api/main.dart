import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/app_services.dart';
import 'package:healthy_cook_api/src/config/env.dart';
import 'package:healthy_cook_api/src/http/cors.dart';

late AppServices services;

Future<void> init(InternetAddress ip, int port) async {
  services = AppServices.fromEnv(Env.load());
}

/// O CORS é aplicado aqui, e não em `routes/_middleware.dart`, para valer
/// também para os arquivos estáticos (as imagens em `/uploads`).
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler.use(cors(services.corsAllowedOrigins)), ip, port);
}
