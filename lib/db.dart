import 'package:sqlite3/sqlite3.dart';

class Db {
  final Database _db;
  final PreparedStatement _getEntityByCoordinates;
  final PreparedStatement _getMapCoordinates;

  Db._(this._db, this._getEntityByCoordinates, this._getMapCoordinates);

  factory Db() {
    final db = sqlite3.openInMemory();

    db.execute('''
      pragma foreign_keys = on;

      create table if not exists entities (
        name text primary key,
        type integer not null,
        x integer not null,
        y integer not null
      ) strict;

      create table if not exists dependencies (
        source text not null,
        destination text not null,
        nominator integer not null,
        denominator integer not null,
        foreign key(source) references entities(name),
        foreign key(destination) references entities(name)
      ) strict;
    ''');

    db.prepare('''
      insert into entities(name, type, x, y) values (?, ?, ?, ?);
    ''')
      ..execute(['Google', 0, 1, 1])
      ..execute(['Fastmail', 0, 1, 2])
      ..execute(['Nazar', 1, 2, 1])
      ..dispose();

    final getEntityByCoordinates = db.prepare('''
      select name, type, x, y from entities where x = ? and y = ?;
    ''');

    final getMapCoordinates = db.prepare('''
      select min(x), min(y), max(x), max(y) from entities;
    ''');

    return Db._(db, getEntityByCoordinates, getMapCoordinates);
  }

  String? getEntityNameByCoordinates(int x, int y) {
    final row = _getEntityByCoordinates.select([x, y]).firstOrNull;

    return switch (row) {
      null => null,
      Row row => row['name'] as String,
    };
  }

  (int, int, int, int) getMapCoordinates() {
    final values = _getMapCoordinates.select().first.values;
    return (
      values[0] as int,
      values[1] as int,
      values[2] as int,
      values[3] as int,
    );
  }
}
