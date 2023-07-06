import 'package:sqlite3/sqlite3.dart';

import 'types.dart';

class _Statements {
  final PreparedStatement selectEntityByPosition;
  final PreparedStatement selectMapBoundaries;
  final PreparedStatement selectEntityDependencyNamesByName;
  final PreparedStatement updateEntityPositionByName;

  const _Statements({
    required this.selectEntityByPosition,
    required this.selectMapBoundaries,
    required this.selectEntityDependencyNamesByName,
    required this.updateEntityPositionByName,
  });
}

class Db {
  final _Statements _statements;

  Db._(this._statements);

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
      ) strict;

      create table if not exists dependencies (
        source text not null,
        destination text not null,
        foreign key(source) references entities(name),
        foreign key(destination) references entities(name),
        primary key(source, destination)
      ) strict;
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
      _Statements(
        selectEntityByPosition: db.prepare('''
          select name, type from entities where x = ? and y = ?;
        '''),
        selectMapBoundaries: db.prepare('''
          select min(x), min(y), max(x), max(y) from entities;
        '''),
        selectEntityDependencyNamesByName: db.prepare('''
          select name from entities
          left join dependencies on destination = name
          where source = ?;
        '''),
        updateEntityPositionByName: db.prepare('''
          update entities
          set x = ?, y = ?
          where name = ?;
        '''),
      ),
    );
  }

  ({
    String name,
    Set<String> dependencyNames,
    EntityType type,
  })? getEntityByPosition({required int x, required int y}) {
    final rows = _statements.selectEntityByPosition.select([x, y]);

    if (rows.isEmpty) {
      return null;
    }

    final name = rows.first['name'] as String;

    return (
      name: name,
      type: EntityType.values[rows.first['type'] as int],
      dependencyNames: _statements.selectEntityDependencyNamesByName
          .select([name])
          .map((row) => row['name'] as String)
          .toSet(),
    );
  }

  ({
    ({int x, int y}) start,
    ({int x, int y}) end,
  }) getMapBoundaries() {
    final values = _statements.selectMapBoundaries.select().first.values;
    return (
      start: (
        x: values[0] as int,
        y: values[1] as int,
      ),
      end: (
        x: values[2] as int,
        y: values[3] as int,
      ),
    );
  }

  void changeEntityPositionByName({
    required String name,
    required int x,
    required int y,
  }) {
    _statements.updateEntityPositionByName.execute([x, y, name]);
  }
}
