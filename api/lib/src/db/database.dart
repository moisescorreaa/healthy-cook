import 'package:mysql_client/mysql_client.dart';

/// Linha retornada por uma consulta, com os valores como texto.
typedef Row = Map<String, String?>;

/// Resultado de um comando de escrita.
class WriteResult {
  const WriteResult({required this.insertId, required this.affectedRows});

  final int insertId;
  final int affectedRows;
}

/// Executor de comandos SQL, implementado pelo [Database] e pelas
/// transações abertas com [Database.transaction].
abstract class SqlExecutor {
  /// Executa um SELECT e retorna as linhas.
  Future<List<Row>> query(String sql, [List<Object?> params = const []]);

  /// Executa um INSERT, UPDATE ou DELETE.
  Future<WriteResult> execute(String sql, [List<Object?> params = const []]);
}

/// Acesso ao MySQL usando prepared statements (`?` como placeholder).
class Database implements SqlExecutor {
  Database(this._pool);

  factory Database.connect({
    required String host,
    required int port,
    required String user,
    required String password,
    required String database,
    int maxConnections = 10,
  }) {
    return Database(
      MySQLConnectionPool(
        host: host,
        port: port,
        userName: user,
        password: password,
        databaseName: database,
        maxConnections: maxConnections,
        collation: 'utf8mb4_unicode_ci',
      ),
    );
  }

  final MySQLConnectionPool _pool;

  @override
  Future<List<Row>> query(
    String sql, [
    List<Object?> params = const [],
  ]) async {
    return _pool.withConnection<List<Row>>(
      (conn) => _Connection(conn).query(sql, params),
    );
  }

  @override
  Future<WriteResult> execute(
    String sql, [
    List<Object?> params = const [],
  ]) async {
    return _pool.withConnection<WriteResult>(
      (conn) => _Connection(conn).execute(sql, params),
    );
  }

  /// Executa [action] dentro de uma transação. Qualquer exceção faz rollback.
  Future<T> transaction<T>(Future<T> Function(SqlExecutor tx) action) {
    return _pool.transactional<T>((conn) => action(_Connection(conn)));
  }

  Future<void> close() => _pool.close();
}

class _Connection implements SqlExecutor {
  _Connection(this._conn);

  final MySQLConnection _conn;

  Future<IResultSet> _run(String sql, List<Object?> params) async {
    final stmt = await _conn.prepare(sql);
    try {
      return await stmt.execute(params);
    } finally {
      await stmt.deallocate();
    }
  }

  @override
  Future<List<Row>> query(String sql, [List<Object?> params = const []]) async {
    final result = await _run(sql, params);
    return [for (final row in result.rows) row.assoc()];
  }

  @override
  Future<WriteResult> execute(
    String sql, [
    List<Object?> params = const [],
  ]) async {
    final result = await _run(sql, params);
    return WriteResult(
      insertId: result.lastInsertID.toInt(),
      affectedRows: result.affectedRows.toInt(),
    );
  }
}

/// Converte valores de [Row] para tipos Dart.
extension RowValues on Row {
  int intValue(String column) => int.parse(this[column]!);

  String stringValue(String column) => this[column]!;

  DateTime dateTimeValue(String column) => parseDateTime(this[column]!);

  DateTime? nullableDateTime(String column) {
    final value = this[column];
    return value == null ? null : parseDateTime(value);
  }
}

/// O MySQL guarda DATETIME em UTC (a API sempre grava em UTC).
DateTime parseDateTime(String value) =>
    DateTime.parse('${value.replaceFirst(' ', 'T')}Z');

/// Formata um [DateTime] para gravação em colunas DATETIME.
String formatDateTime(DateTime value) =>
    value.toUtc().toIso8601String().substring(0, 19).replaceFirst('T', ' ');
