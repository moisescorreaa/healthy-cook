import 'package:flutter/material.dart';
import 'package:healthy_cook/color_scheme.dart';
import 'package:healthy_cook/views/register_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      routes: {
        '/': (context) => RegisterPage(),
      },
      initialRoute: '/',
    );
  }
}
