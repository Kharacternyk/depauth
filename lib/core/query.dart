import 'package:sqlite3/sqlite3.dart';

typedef Values = List<Object?>;

class Query {
  final PreparedStatement _statement;

  Query(Database database, String sql) : _statement = database.prepare(sql);

  List<T> select<T>(Values? parameters, T Function(Values) factory) {
    final result = <T>[];
    final cursor = _statement.selectCursor(parameters ?? const []);

    while (cursor.moveNext()) {
      result.add(factory(cursor.current.values));
    }

    return result;
  }

  Values? selectOne([Values? parameters]) {
    return _statement.select(parameters ?? const []).firstOrNull?.values;
  }
}
