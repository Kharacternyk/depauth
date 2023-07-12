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

  ValueNotifier<EntityVertex?> _cacheEntity(Position position) {
    final entity = ValueNotifier(_getEntity(position));

    _entities[position] = WeakReference(entity);

    return entity;
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
    order by x, y
  ''');
  EntityVertex? _getEntity(Position position) {
    final row =
        _getEntityStatement.select([position.x, position.y]).firstOrNull;
    return switch (row) {
      null => null,
      Row row => EntityVertex(
          _parseEntity(row),
          _getDependenciesStatement
              .select([row['name']])
              .map(_parseEntity)
              .toList(),
        ),
    };
  }

  Entity _parseEntity(Row row) => Entity(
        row['name'] as String,
        EntityType.values[row['type'] as int],
      );

  late final _moveEntityStatement = db.prepare('''
    update entities
    set x = ?, y = ?
    where x = ? and y = ?
  ''');
  void moveEntity({required Position from, required Position to}) {
    _moveEntityStatement.execute(
      [to.x, to.y, from.x, from.y],
    );

    _entities[from]?.target?.value = null;
    _updateEntity(to);
    for (final position in _getDependantPositions(to)) {
      _updateEntity(position);
    }

    boundaries.value = _getBoundaries();
  }

  void _updateEntity(Position position) {
    _entities[position]?.target?.value = _getEntity(position);
  }

  late final _getBoundariesStatement = db.prepare('''
    select min(x), min(y), max(x), max(y)
    from entities
  ''');
  Boundaries _getBoundaries() {
    final values = _getBoundariesStatement.select().first.values;
    return Boundaries(
      Position(values[0] as int, values[1] as int),
      Position(values[2] as int, values[3] as int),
    );
  }

  late final _getDependantPositionsStatement = db.prepare('''
    select sources.x, sources.y
    from entities as sources
    join dependencies
    on sources.name = source
    join entities as destinations
    on destinations.name = destination
    where destinations.x = ? and destinations.y = ?
  ''');
  Iterable<Position> _getDependantPositions(Position position) =>
      _getDependantPositionsStatement.select([position.x, position.y]).map(
          (row) => Position(row['x'] as int, row['y'] as int));

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
      insert into entities(name, type, x, y) values (?, ?, ?, ?)
    ''')
      ..execute(['Google', 0, 1, 1])
      ..execute(['Fastmail', 0, 1, 2])
      ..execute(['Yubikey', 1, 1, 3])
      ..execute(['Nazar', 2, 2, 1])
      ..dispose();

    db.prepare('''
      insert into dependencies(source, destination) values (?, ?)
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
