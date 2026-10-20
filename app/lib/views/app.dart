import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:healthy_cook/config/color_schemes.dart';
import 'package:healthy_cook/config/custom_color.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:healthy_cook/views/initial_page.dart';
import 'package:healthy_cook/views/login_page.dart';
import 'package:healthy_cook/views/main_management_page.dart';
import 'package:healthy_cook/views/register_page.dart';
import 'package:healthy_cook/views/reset_password_page.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthController _auth;
  late AuthStatus _lastStatus;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthController>();
    _lastStatus = _auth.status;
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// Ao sair (ou quando a sessão expira), volta para a tela inicial.
  void _onAuthChanged() {
    final status = _auth.status;
    if (_lastStatus == AuthStatus.authenticated &&
        status == AuthStatus.unauthenticated) {
      _navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/', (route) => false);
    }
    _lastStatus = status;
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightScheme;

      if (lightDynamic != null) {
        lightScheme = lightDynamic.harmonized();
        lightCustomColors = lightCustomColors.harmonized(lightScheme);
      } else {
        lightScheme = lightColorScheme;
      }

      return MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightScheme,
          extensions: [lightCustomColors],
        ),
        routes: {
          '/': (context) => const InitialPage(),
          '/register': (context) => const RegisterPage(),
          '/login': (context) => const LoginPage(),
          '/reset-password': (context) => const ResetPasswordPage(),
          '/home': (context) => const MainManagementPage(),
        },
        // Com a sessão restaurada, abre direto no início, sem a tela de boas-
        // vindas por baixo (o initialRoute '/home' empilharia '/' antes).
        onGenerateInitialRoutes: (_) => [
          _auth.status == AuthStatus.authenticated
              ? MaterialPageRoute(
                  settings: const RouteSettings(name: '/home'),
                  builder: (_) => const MainManagementPage(),
                )
              : MaterialPageRoute(
                  settings: const RouteSettings(name: '/'),
                  builder: (_) => const InitialPage(),
                ),
        ],
      );
    });
  }
}
