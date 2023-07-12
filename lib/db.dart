import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'types.dart';

class Db {
  final Database db;
  late final ValueNotifier<Boundaries> boundaries = ValueNotifier(
    _getBoundaries(),
  );

  final Map<Position, WeakReference<ValueNotifier<EntityVertex?>>> _entities =
      {};

  ValueNotifier<EntityVertex?> getEntity(Position position) {
    return switch (_entities[position]) {
      null => _cacheEntity(position),
      WeakReference<ValueNotifier<EntityVertex?>> reference => switch (
            reference.target) {
          null => _cacheEntity(position),
          ValueNotifier<EntityVertex?> entity => entity,
        },
    };
  }

  late final PreparedStatement _getEntityStatement = db.prepare('''
    select name, type
    from entities
    where x = ? and y = ?
  ''');
  late final PreparedStatement _getDependenciesStatement = db.prepare('''
    select name, type
    from entities
    join dependencies
    on name = destination
    where source = ?
  ''');

  ValueNotifier<EntityVertex?> _cacheEntity(Position position) {
    final row =
        _getEntityStatement.select([position.x, position.y]).firstOrNull;
    final entity = ValueNotifier(switch (row) {
      null => null,
      Row row => EntityVertex(
          _parseEntity(row),
          _getDependenciesStatement
              .select([row['name']])
              .map(_parseEntity)
              .toList(),
        ),
    });

    _entities[position] = WeakReference(entity);

    return entity;
  }

  Entity _parseEntity(Row row) => Entity(
        row['name'] as String,
        EntityType.values[row['type'] as int],
      );

  late final _moveEntityStatement = db.prepare('''
    update entities
    set x = ?, y = ?
    where x = ? and y = ?;
  ''');

  void moveEntity({required Position from, required Position to}) {
    _moveEntityStatement.execute(
      [to.x, to.y, from.x, from.y],
    );

    _entities[to]?.target?.value = _entities[from]?.target?.value;
    _entities[from]?.target?.value = null;
    boundaries.value = _getBoundaries();
  }

  late final _getBoundariesStatement = db.prepare('''
    select min(x), min(y), max(x), max(y)
    from entities;
  ''');

  Boundaries _getBoundaries() {
    final values = _getBoundariesStatement.select().first.values;
    return Boundaries(
      Position(values[0] as int, values[1] as int),
      Position(values[2] as int, values[3] as int),
    );
  }

  Db() : db = sqlite3.openInMemory() {
    db.execute('''
      pragma foreign_keys = on;

      create table if not exists entities (
        name text not null primary key,
        type integer not null,
        x integer not null,
        y integer not null,
        unique(x, y)
      ) strict, without rowid;

      create table if not exists dependencies (
        source text not null references entities on delete cascade,
        destination text not null references entities on delete cascade,
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
      ..execute(['Google', 'Yubikey'])
      ..execute(['Fastmail', 'Yubikey'])
      ..dispose();
  }
}
