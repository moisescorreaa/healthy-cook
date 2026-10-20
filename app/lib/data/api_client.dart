import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'token_storage.dart';

/// Imagem escolhida pelo usuário, pronta para envio.
class ImageUpload {
  const ImageUpload({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;

  String get mimeType {
    final name = filename.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

/// Cliente HTTP da API do Healthy Cook.
///
/// Envia o access token em toda requisição autenticada e, quando ele expira
/// (401), usa o refresh token para obter um novo par e repete a requisição.
/// Se a renovação falhar, limpa a sessão e chama [onSessionExpired].
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required TokenStorage tokenStorage,
    http.Client? httpClient,
  })  : _tokenStorage = tokenStorage,
        _http = httpClient ?? http.Client();

  static const _timeout = Duration(seconds: 20);

  final Uri baseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _http;

  /// Chamado quando a sessão expira e o usuário precisa entrar de novo.
  void Function()? onSessionExpired;

  AuthTokens? _tokens;
  bool _tokensLoaded = false;
  Future<bool>? _refreshing;

  /// Indica se existe uma sessão salva.
  Future<bool> hasSession() async => await _currentTokens() != null;

  Future<void> saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
    _tokensLoaded = true;
    await _tokenStorage.write(tokens);
  }

  Future<void> clearTokens() async {
    _tokens = null;
    _tokensLoaded = true;
    await _tokenStorage.clear();
  }

  Future<String?> currentRefreshToken() async =>
      (await _currentTokens())?.refreshToken;

  /// Converte URLs relativas da API (ex.: `/uploads/...`) em absolutas.
  String? resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return baseUrl.resolve(url).toString();
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) =>
      _sendJson('GET', path, query: query, auth: auth);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _sendJson('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, {Object? body}) =>
      _sendJson('PUT', path, body: body);

  Future<dynamic> patch(String path, {Object? body}) =>
      _sendJson('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _sendJson('DELETE', path);

  /// Envia uma imagem como multipart no campo `image`.
  Future<dynamic> uploadImage(String path, ImageUpload image) {
    return _send(
        auth: true,
        build: () {
          final [type, subtype] = image.mimeType.split('/');
          return http.MultipartRequest('PUT', _uri(path))
            ..files.add(
              http.MultipartFile.fromBytes(
                'image',
                image.bytes,
                filename: image.filename,
                contentType: http.MediaType(type, subtype),
              ),
            );
        });
  }

  Future<dynamic> _sendJson(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool auth = true,
  }) {
    return _send(
        auth: auth,
        build: () {
          final request = http.Request(method, _uri(path, query));
          if (body != null) {
            request.headers['content-type'] = 'application/json; charset=utf-8';
            request.body = jsonEncode(body);
          }
          return request;
        });
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = baseUrl.resolve(path);
    return query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: query);
  }

  /// [build] cria uma requisição nova a cada tentativa, pois uma requisição
  /// do pacote http não pode ser enviada duas vezes.
  Future<dynamic> _send({
    required bool auth,
    required http.BaseRequest Function() build,
  }) async {
    var response = await _execute(build(), auth: auth);
    if (response.statusCode == 401 && auth && await _refreshTokens()) {
      response = await _execute(build(), auth: auth);
    }
    return _decode(response);
  }

  Future<http.Response> _execute(
    http.BaseRequest request, {
    required bool auth,
  }) async {
    request.headers['accept'] = 'application/json';
    if (auth) {
      final tokens = await _currentTokens();
      if (tokens != null) {
        request.headers['authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    try {
      final streamed = await _http.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException.network();
    } on http.ClientException {
      throw const ApiException.network();
    }
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    Object? body;
    if (text.isNotEmpty &&
        (response.headers['content-type'] ?? '').contains('json')) {
      body = jsonDecode(text);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    throw ApiException.fromResponse(response.statusCode, body);
  }

  /// Renova os tokens. Chamadas simultâneas compartilham a mesma renovação,
  /// pois cada refresh token só pode ser usado uma vez.
  Future<bool> _refreshTokens() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = (await _currentTokens())?.refreshToken;
    if (refreshToken == null) return false;

    final request = http.Request('POST', _uri('/auth/refresh'))
      ..headers['content-type'] = 'application/json; charset=utf-8'
      ..body = jsonEncode({'refreshToken': refreshToken});
    final response = await _execute(request, auth: false);

    if (response.statusCode == 200) {
      final json = _decode(response) as Map<String, dynamic>;
      await saveTokens(AuthTokens.fromJson(json));
      return true;
    }
    if (response.statusCode == 401) {
      await clearTokens();
      onSessionExpired?.call();
    }
    return false;
  }

  Future<AuthTokens?> _currentTokens() async {
    if (!_tokensLoaded) {
      _tokens = await _tokenStorage.read();
      _tokensLoaded = true;
    }
    return _tokens;
  }
}
