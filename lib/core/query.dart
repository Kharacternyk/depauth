import 'package:sqlite3/sqlite3.dart';

class Query {
  final PreparedStatement _statement;

  Query(Database db, String sql)
      : _statement = db.prepare(sql, persistent: true);

  ResultSet select([List<Object?> parameters = const []]) {
    return _statement.select(parameters);
  }
}
