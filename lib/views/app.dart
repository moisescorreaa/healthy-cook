import 'package:flutter/material.dart';
import 'package:healthy_cook/color_scheme.dart';
import 'package:healthy_cook/views/home_page.dart';
import 'package:healthy_cook/views/login_page.dart';
import 'package:healthy_cook/views/register_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: 'Roboto'),
      routes: {
        '/': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      initialRoute: '/',
    );
  }
}
