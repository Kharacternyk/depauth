import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'boundaries.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'position.dart';
import 'traversable_entity.dart';

class Db {
  final Database _db;
  final Map<Position, WeakReference<ValueNotifier<TraversableEntity?>>>
      _entities = {};

  late final ValueNotifier<Boundaries> boundaries = ValueNotifier(
    _getBoundaries(),
  );

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

  late final PreparedStatement _getEntityStatement = _db.prepare('''
    select name, type
    from entities
    where x = ? and y = ?
  ''');
  late final PreparedStatement _getDependenciesStatement = _db.prepare('''
    select name, type
    from entities
    join dependencies
    on name = entity
    where factor = ?
    order by x, y
  ''');
  late final PreparedStatement _getFactorsStatement = _db.prepare('''
    select id
    from factors
    join dependencies
    on id = factor
    join entities
    on dependencies.entity = name
    where factors.entity = ?
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
          _getFactorsStatement.select([row['name']]).map((row) =>
              _getDependenciesStatement.select([row['id']]).map((row) => Entity(
                    row['name'] as String,
                    EntityType.values[row['type'] as int],
                  ))),
        ),
    };
  }

  late final _moveEntityStatement = _db.prepare('''
    update entities
    set x = ?, y = ?
    where x = ? and y = ?
  ''');
  void moveEntity({required Position from, required Position to}) {
    _moveEntityStatement.execute(
      [to.x, to.y, from.x, from.y],
    );

    _updateEntities([from, to, ..._getDependantPositions(from)]);
    _updateBoundaries();
  }

  late final _deleteEntityStatement = _db.prepare('''
    delete from entities
    where x = ? and y = ?
  ''');
  void deleteEntity(Position position) {
    final dependants = _getDependantPositions(position);

    _deleteEntityStatement.execute([position.x, position.y]);

    _updateEntities([position, ...dependants]);
    _updateBoundaries();
  }

  void _updateBoundaries() {
    boundaries.value = _getBoundaries();
  }

  void _updateEntities(Iterable<Position> positions) {
    for (final position in positions) {
      _entities[position]?.target?.value = _getEntity(position);
    }
  }

  late final _getBoundariesStatement = _db.prepare('''
    select min(x) - 1, min(y) - 1, max(x) + 1, max(y) + 1
    from entities
  ''');
  Boundaries _getBoundaries() {
    final values = _getBoundariesStatement.select().first.values;
    return Boundaries(
      Position(values[0] as int? ?? 0, values[1] as int? ?? 0),
      Position(values[2] as int? ?? 0, values[3] as int? ?? 0),
    );
  }

  late final _getDependantPositionsStatement = _db.prepare('''
    select sources.x, sources.y
    from entities as sources
    join factors
    on sources.name = factors.entity
    join dependencies
    on factor = id
    join entities as targets
    on targets.name = dependencies.entity
    where targets.x = ? and targets.y = ?
  ''');
  Iterable<Position> _getDependantPositions(Position position) =>
      _getDependantPositionsStatement.select([position.x, position.y]).map(
          (row) => Position(row['x'] as int, row['y'] as int));

  Db() : _db = sqlite3.openInMemory() {
    _db.execute('''
      pragma foreign_keys = on;

      create table if not exists entities (
        name text not null primary key,
        type integer not null,
        x integer not null,
        y integer not null,
        unique(x, y)
      ) strict, without rowid;

      create table if not exists factors (
        id integer not null primary key,
        entity text not null references entities on update cascade on delete cascade
      ) strict;

      create table if not exists dependencies (
        factor integer not null references factors on delete cascade,
        entity text not null references entities on update cascade on delete cascade,
        primary key(entity, factor)
      ) strict, without rowid;
    ''');

    _db.prepare('''
      insert into entities(name, type, x, y) values (?, ?, ?, ?)
    ''')
      ..execute(['Google', 0, 1, 1])
      ..execute(['Fastmail', 0, 1, 2])
      ..execute(['Yubikey', 1, 1, 3])
      ..execute(['Nazar', 2, 2, 1])
      ..dispose();

    _db.prepare('''
      insert into factors(id, entity) values (?, ?)
    ''')
      ..execute([0, 'Google'])
      ..execute([1, 'Fastmail'])
      ..execute([2, 'Google'])
      ..execute([3, 'Fastmail'])
      ..dispose();

    _db.prepare('''
      insert into dependencies(factor, entity) values (?, ?)
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
