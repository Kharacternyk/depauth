import 'package:sqlite3/sqlite3.dart';

class Statement {
  final PreparedStatement _statement;

  Statement(Database database, String sql) : _statement = database.prepare(sql);

  void execute([List<Object?> parameters = const []]) {
    _statement.execute(parameters);
    _statement.reset();
  }
}
