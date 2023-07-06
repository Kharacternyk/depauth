import 'package:sqlite3/sqlite3.dart';

class Db {
  final PreparedStatement selectEntityNameByCoordinates;
  final PreparedStatement selectMapCoordinates;
  final PreparedStatement selectEntityDependencyNamesByName;
  final PreparedStatement updateEntityCoordinatesByName;

  Db._({
    required this.selectEntityNameByCoordinates,
    required this.selectMapCoordinates,
    required this.selectEntityDependencyNamesByName,
    required this.updateEntityCoordinatesByName,
  });

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

    db.prepare('''
      insert into dependencies(source, destination) values (?, ?);
    ''')
      ..execute(['Google', 'Fastmail'])
      ..execute(['Fastmail', 'Google'])
      ..execute(['Nazar', 'Google'])
      ..execute(['Nazar', 'Fastmail'])
      ..dispose();

    return Db._(
      selectEntityNameByCoordinates: db.prepare('''
        select name, type, x, y from entities where x = ? and y = ?;
      '''),
      selectMapCoordinates: db.prepare('''
        select min(x), min(y), max(x), max(y) from entities;
      '''),
      selectEntityDependencyNamesByName: db.prepare('''
        select name from entities
        left join dependencies on destination = name
        where source = ?;
      '''),
      updateEntityCoordinatesByName: db.prepare('''
        update entities
        set x = ?, y = ?
        where name = ?;
      '''),
    );
  }

  (String, Set<String>)? getEntityNameAndDependenciesByCoordinates(
      int x, int y) {
    final rows = selectEntityNameByCoordinates.select([x, y]);

    if (rows.isEmpty) {
      return null;
    }

    final name = rows.first['name'] as String;

    return (
      name,
      selectEntityDependencyNamesByName
          .select([name])
          .map((row) => row['name'] as String)
          .toSet(),
    );
  }

  (int, int, int, int) getMapCoordinates() {
    final values = selectMapCoordinates.select().first.values;
    return (
      values[0] as int,
      values[1] as int,
      values[2] as int,
      values[3] as int,
    );
  }

  void changeEntityCoordinatesByName(String name, int x, int y) {
    updateEntityCoordinatesByName.execute([x, y, name]);
  }
}
