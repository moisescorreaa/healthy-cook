import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_cook/data/api_client.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response json(int status, Object? body) => http.Response(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  late MemoryTokenStorage storage;

  setUp(() {
    storage = MemoryTokenStorage()
      ..tokens = const AuthTokens(accessToken: 'old', refreshToken: 'r1');
  });

  ApiClient client(MockClientHandler handler) => ApiClient(
        baseUrl: Uri.parse('http://api.test'),
        tokenStorage: storage,
        httpClient: MockClient(handler),
      );

  test('envia o access token no header Authorization', () async {
    final api = client((request) async {
      expect(request.headers['authorization'], 'Bearer old');
      return json(200, {'ok': true});
    });
    expect(await api.get('/users/me'), {'ok': true});
  });

  test('renova o token após 401 e repete a requisição', () async {
    final calls = <String>[];
    final api = client((request) async {
      calls.add('${request.method} ${request.url.path} '
          '${request.headers['authorization'] ?? ''}');
      if (request.url.path == '/auth/refresh') {
        expect(jsonDecode(request.body), {'refreshToken': 'r1'});
        return json(200, {'accessToken': 'new', 'refreshToken': 'r2'});
      }
      return request.headers['authorization'] == 'Bearer new'
          ? json(200, {'ok': true})
          : json(401, {
              'error': {'code': 'unauthorized', 'message': 'expirado'},
            });
    });

    expect(await api.get('/users/me'), {'ok': true});
    expect(calls, [
      'GET /users/me Bearer old',
      'POST /auth/refresh ',
      'GET /users/me Bearer new',
    ]);
    expect(storage.tokens?.refreshToken, 'r2');
  });

  test('requisições simultâneas compartilham uma única renovação', () async {
    var refreshes = 0;
    final api = client((request) async {
      if (request.url.path == '/auth/refresh') {
        refreshes++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return json(200, {'accessToken': 'new', 'refreshToken': 'r2'});
      }
      return request.headers['authorization'] == 'Bearer new'
          ? json(200, {'path': request.url.path})
          : json(401, null);
    });

    final results = await Future.wait([
      api.get('/recipes'),
      api.get('/users/me'),
      api.get('/users/me/recipes'),
    ]);
    expect(results, hasLength(3));
    expect(refreshes, 1);
  });

  test('refresh recusado limpa a sessão e avisa o app', () async {
    var expired = false;
    final api = client((request) async => json(401, {
          'error': {'code': 'invalid_refresh_token', 'message': 'expirada'},
        }))
      ..onSessionExpired = () => expired = true;

    await expectLater(
      api.get('/users/me'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    expect(expired, isTrue);
    expect(storage.tokens, isNull);
    expect(await api.hasSession(), isFalse);
  });

  test('converte o erro da API em ApiException com detalhes', () async {
    final api = client((request) async => json(400, {
          'error': {
            'code': 'bad_request',
            'message': 'Dados inválidos',
            'details': {'email': 'E-mail inválido'},
          },
        }));

    await expectLater(
      api.post('/auth/login', body: {}, auth: false),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'bad_request')
          .having((e) => e.userMessage, 'userMessage',
              'Dados inválidos: E-mail inválido')),
    );
  });

  test('falha de rede vira ApiException.network', () async {
    final api = client((request) async => throw http.ClientException('off'));
    await expectLater(
      api.get('/recipes'),
      throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'network_error')),
    );
  });

  test('resolve URLs relativas de imagens contra a API', () {
    final api = client((_) async => json(200, null));
    expect(api.resolveUrl('/uploads/a.jpg'), 'http://api.test/uploads/a.jpg');
    expect(api.resolveUrl('https://cdn.test/b.jpg'), 'https://cdn.test/b.jpg');
    expect(api.resolveUrl(null), isNull);
  });

  test('envia imagem como multipart no campo image', () async {
    final api = client((request) async {
      expect(request.method, 'PUT');
      expect(
          request.headers['content-type'], startsWith('multipart/form-data'));
      final body = utf8.decode(request.bodyBytes, allowMalformed: true);
      expect(body, contains('name="image"; filename="foto.png"'));
      expect(body, contains('content-type: image/png'));
      return json(200, {'ok': true});
    });
    await api.uploadImage(
      '/users/me/photo',
      ImageUpload(bytes: utf8.encode('png'), filename: 'foto.png'),
    );
  });
}
