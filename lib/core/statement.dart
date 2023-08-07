import 'package:sqlite3/sqlite3.dart';

class Statement {
  final PreparedStatement _statement;

  Statement(Database database, String sql, {bool cold = false})
      : _statement = database.prepare(sql, persistent: !cold);

  void execute([List<Object?> parameters = const []]) {
    _statement
      ..execute(parameters)
      ..reset();
  }
}
