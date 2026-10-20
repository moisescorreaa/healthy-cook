import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:healthy_cook/config/api_config.dart';
import 'package:healthy_cook/data/api_client.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:healthy_cook/data/token_storage.dart';
import 'package:healthy_cook/views/app.dart';
import 'package:provider/provider.dart';

void main() async {
  // Mantém o splash enquanto a sessão salva é restaurada.
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );

  final api = ApiClient(
    baseUrl: apiBaseUrl(),
    tokenStorage: SecureTokenStorage(),
  );
  final auth = AuthController(api);
  await auth.restoreSession();
  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => RecipeRepository(api)),
      ],
      child: const App(),
    ),
  );
}
