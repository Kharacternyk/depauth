import 'package:sqlite3/sqlite3.dart';

class Query {
  final PreparedStatement _statement;

  Query(Database database, String sql) : _statement = database.prepare(sql);

  List<T> select<T>(
    List<Object?>? parameters,
    T Function(Row) factory,
  ) {
    final result = <T>[];
    final cursor = _statement.selectCursor(parameters ?? const []);

    while (cursor.moveNext()) {
      result.add(factory(cursor.current));
    }

    return result;
  }

  List<Object?>? selectOne([List<Object?>? parameters]) {
    return _statement.select(parameters ?? const []).firstOrNull?.values;
  }
}
