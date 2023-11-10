import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:healthy_cook/config/color_schemes.dart';
import 'package:healthy_cook/config/custom_color.dart';
import 'package:healthy_cook/views/initial_page.dart';
import 'package:healthy_cook/views/main_management_page.dart';
import 'package:healthy_cook/views/login_page.dart';
import 'package:healthy_cook/views/register_page.dart';

class App extends StatelessWidget {
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
          '/home': (context) => const MainManagementPage(),
        },
        initialRoute: '/',
      );
    });
  }
}
