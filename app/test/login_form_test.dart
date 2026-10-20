import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_cook/components/login_form.dart';
import 'package:healthy_cook/data/api_client.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:healthy_cook/data/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  late List<http.Request> requests;
  late http.Response loginResponse;

  Future<AuthController> pumpLogin(WidgetTester tester) async {
    requests = [];
    final api = ApiClient(
      baseUrl: Uri.parse('http://api.test'),
      tokenStorage: MemoryTokenStorage(),
      httpClient: MockClient((request) async {
        requests.add(request);
        return loginResponse;
      }),
    );
    final auth = AuthController(api);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          routes: {'/home': (_) => const Text('HOME')},
          home: const Scaffold(body: SingleChildScrollView(child: LoginForm())),
        ),
      ),
    );
    return auth;
  }

  Future<void> fillAndSubmit(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  testWidgets('valida o e-mail antes de chamar a API', (tester) async {
    await pumpLogin(tester);
    await fillAndSubmit(tester, 'invalido');
    expect(find.text('Por favor, insira um email válido.'), findsOneWidget);
    expect(requests, isEmpty);
  });

  testWidgets('mostra erro de credenciais inválidas', (tester) async {
    loginResponse = http.Response(
      jsonEncode({
        'error': {'code': 'invalid_credentials', 'message': 'x'},
      }),
      401,
      headers: {'content-type': 'application/json'},
    );
    final auth = await pumpLogin(tester);
    await fillAndSubmit(tester, 'ana@teste.com');
    expect(find.text('Email ou senha inválidos.'), findsOneWidget);
    expect(auth.status, AuthStatus.unknown);
  });

  testWidgets('login com sucesso abre o início', (tester) async {
    loginResponse = http.Response(
      jsonEncode({
        'user': {
          'id': 1,
          'name': 'Ana',
          'email': 'ana@teste.com',
          'photoUrl': null,
          'emailVerified': false,
        },
        'accessToken': 'a',
        'refreshToken': 'r',
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
    final auth = await pumpLogin(tester);
    await fillAndSubmit(tester, ' ana@teste.com ');

    expect(jsonDecode(requests.single.body),
        {'email': 'ana@teste.com', 'password': 'senha123'});
    expect(auth.status, AuthStatus.authenticated);
    expect(auth.user?.name, 'Ana');
    expect(find.text('HOME'), findsOneWidget);
  });
}
