import 'package:sqlite3/sqlite3.dart';

typedef Values = List<Object?>;

class Query {
  final PreparedStatement _statement;

  Query(Database database, String sql) : _statement = database.prepare(sql);

  Iterable<T> select<T>(Values? parameters, T Function(Values) create) {
    return selectLazy(parameters).map(create).toList();
  }

  Values? selectOne([Values? parameters]) {
    return selectLazy(parameters).firstOrNull;
  }

  Iterable<Values> selectLazy([Values? parameters]) sync* {
    final cursor = _statement.selectCursor(parameters ?? const []);

    while (cursor.moveNext()) {
      yield cursor.current.values;
    }
  }
}
