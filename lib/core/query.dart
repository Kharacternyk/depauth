import 'package:sqlite3/sqlite3.dart';

class Query {
  final PreparedStatement _statement;

  Query(Database database, String sql)
      : _statement = database.prepare(sql, persistent: true);

  ResultSet select([List<Object?> parameters = const []]) {
    return _statement.select(parameters);
  }
}
