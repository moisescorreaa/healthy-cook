import 'package:dart_frog/dart_frog.dart';

/// Lê `limit` (1–50, padrão 20) e `offset` da query string.
({int limit, int offset}) readPagination(RequestContext context) {
  final params = context.request.uri.queryParameters;
  final limit = (int.tryParse(params['limit'] ?? '') ?? 20).clamp(1, 50);
  final offset = (int.tryParse(params['offset'] ?? '') ?? 0).clamp(0, 1 << 30);
  return (limit: limit, offset: offset);
}
