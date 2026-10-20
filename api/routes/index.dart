import 'package:dart_frog/dart_frog.dart';
import 'package:healthy_cook_api/src/db/database.dart';

/// Health check: confirma que a API está no ar e o banco responde.
Future<Response> onRequest(RequestContext context) async {
  await context.read<Database>().query('SELECT 1');
  return Response.json(body: {'status': 'ok'});
}
