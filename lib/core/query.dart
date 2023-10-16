import 'package:sqlite3/sqlite3.dart';

typedef Values = List<Object?>;

class Query {
  final PreparedStatement _statement;

  Query(Database database, String sql) : _statement = database.prepare(sql);

  Iterable<T> select<T>(Values? parameters, T Function(Values) create) {
    return _select(parameters).map(create).toList();
  }

  Iterable<T> selectThrough<R, T>(
    Values? parameters,
    R Function(Values) create,
    Iterable<T> Function(Iterable<R>) combine, [
    Comparator<T>? compare,
  ]) {
    final result = combine(_select(parameters).map(create)).toList();

    if (compare != null) {
      result.sort(compare);
    }

    return result;
  }

  Values? selectOne([Values? parameters]) {
    return _select(parameters).firstOrNull;
  }

  Iterable<Values> _select(Values? parameters) sync* {
    final cursor = _statement.selectCursor(parameters ?? const []);

    while (cursor.moveNext()) {
      yield cursor.current.values;
    }
  }
}
