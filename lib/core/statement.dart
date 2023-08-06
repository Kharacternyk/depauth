import 'package:sqlite3/sqlite3.dart';

class Statement {
  final Iterable<PreparedStatement> _statements;

  Statement(Database database, String sql)
      : _statements = database.prepareMultiple(sql, persistent: true);

  void execute([List<Object?> parameters = const []]) {
    for (final statement in _statements) {
      statement
        ..execute(parameters)
        ..reset();
    }
  }
}
