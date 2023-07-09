import 'package:sqlite3/sqlite3.dart';

import 'types.dart';

class Db {
  final (Position, Position) Function() getMapBoundaries;
  final void Function({
    required Position newPosition,
    required Position oldPosition,
  }) setEntityPosition;
  final ({
    String name,
    EntityType type,
  })?
      Function(Position position) getEntityByPosition;

  Db._({
    required this.getMapBoundaries,
    required this.setEntityPosition,
    required this.getEntityByPosition,
  });

  factory Db() {
    final db = sqlite3.openInMemory();

    db.execute('''
      pragma foreign_keys = on;

      create table if not exists entities (
        name text primary key,
        type integer not null,
        x integer not null,
        y integer not null,
        unique(x, y)
      ) strict, without rowid;

      create table if not exists dependencies (
        source text not null references entities on update cascade,
        destination text not null references entities on update cascade,
        primary key(source, destination)
      ) strict, without rowid;
    ''');

    db.prepare('''
      insert into entities(name, type, x, y) values (?, ?, ?, ?);
    ''')
      ..execute(['Google', 0, 1, 1])
      ..execute(['Fastmail', 0, 1, 2])
      ..execute(['Yubikey', 1, 1, 3])
      ..execute(['Nazar', 2, 2, 1])
      ..dispose();

    db.prepare('''
      insert into dependencies(source, destination) values (?, ?);
    ''')
      ..execute(['Google', 'Fastmail'])
      ..execute(['Fastmail', 'Google'])
      ..execute(['Google', 'Nazar'])
      ..execute(['Fastmail', 'Nazar'])
      ..dispose();

    return Db._(
      getMapBoundaries: () {
        final statement = db.prepare('''
          select min(x), min(y), max(x), max(y)
          from entities;
        ''');

        return () {
          final values = statement.select().first.values;
          return (
            Position(values[0] as int, values[1] as int),
            Position(values[2] as int, values[3] as int),
          );
        };
      }(),
      setEntityPosition: () {
        final statement = db.prepare('''
          update entities
          set x = ?, y = ?
          where x = ? and y = ?;
        ''');

        return ({
          required Position newPosition,
          required Position oldPosition,
        }) {
          statement.execute(
            [newPosition.x, newPosition.y, oldPosition.x, oldPosition.y],
          );
        };
      }(),
      getEntityByPosition: () {
        final statement = db.prepare('''
          select name, type
          from entities
          where x = ? and y = ?
        ''');

        return (Position position) {
          final row = statement.select([position.x, position.y]).firstOrNull;
          return switch (row) {
            null => null,
            Row row => (
                name: row['name'] as String,
                type: EntityType.values[row['type'] as int],
              ),
          };
        };
      }(),
    );
  }
}
