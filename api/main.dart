import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/app_services.dart';
import 'package:healthy_cook_api/src/config/env.dart';

late AppServices services;

Future<void> init(InternetAddress ip, int port) async {
  services = AppServices.fromEnv(Env.load());
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
