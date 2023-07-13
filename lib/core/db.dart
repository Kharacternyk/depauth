import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'boundaries.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'position.dart';
import 'traversable_entity.dart';

class Db {
  final Database db;
  late final ValueNotifier<Boundaries> boundaries = ValueNotifier(
    _getBoundaries(),
  );

  final Map<Position, WeakReference<ValueNotifier<TraversableEntity?>>>
      _entities = {};

  ValueNotifier<TraversableEntity?> getEntity(Position position) {
    return switch (_entities[position]) {
      null => _cacheEntity(position),
      WeakReference<ValueNotifier<TraversableEntity?>> reference => switch (
            reference.target) {
          null => _cacheEntity(position),
          ValueNotifier<TraversableEntity?> entity => entity,
        },
    };
  }

  ValueNotifier<TraversableEntity?> _cacheEntity(Position position) {
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
    on name = entity
    where dependency_group = ?
    order by x, y
  ''');
  late final PreparedStatement _getDependencyGroupsStatement = db.prepare('''
    select id
    from dependency_groups
    join dependencies
    on id = dependency_group
    join entities
    on dependencies.entity = name
    where dependency_groups.entity = ?
    group by id
    order by min(entities.x), min(entities.y)
  ''');
  TraversableEntity? _getEntity(Position position) {
    final row =
        _getEntityStatement.select([position.x, position.y]).firstOrNull;
    return switch (row) {
      null => null,
      Row row => TraversableEntity(
          row['name'] as String,
          EntityType.values[row['type'] as int],
          _getDependencyGroupsStatement.select([row['name']]).map((row) =>
              _getDependenciesStatement.select([row['id']]).map((row) => Entity(
                    row['name'] as String,
                    EntityType.values[row['type'] as int],
                  ))),
        ),
    };
  }

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
    join dependency_groups
    on sources.name = dependency_groups.entity
    join dependencies
    on dependency_group = id
    join entities as targets
    on targets.name = dependencies.entity
    where targets.x = ? and targets.y = ?
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

      create table if not exists dependency_groups (
        id integer not null primary key,
        entity text not null references entities on update cascade on delete cascade
      ) strict;

      create table if not exists dependencies (
        dependency_group integer not null references dependency_groups on delete cascade,
        entity text not null references entities on update cascade on delete cascade,
        primary key(entity, dependency_group)
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
      insert into dependency_groups(id, entity) values (?, ?)
    ''')
      ..execute([0, 'Google'])
      ..execute([1, 'Fastmail'])
      ..execute([2, 'Google'])
      ..execute([3, 'Fastmail'])
      ..dispose();

    db.prepare('''
      insert into dependencies(dependency_group, entity) values (?, ?)
    ''')
      ..execute([0, 'Fastmail'])
      ..execute([1, 'Google'])
      ..execute([0, 'Nazar'])
      ..execute([1, 'Nazar'])
      ..execute([2, 'Yubikey'])
      ..execute([3, 'Yubikey'])
      ..dispose();
  }
}
