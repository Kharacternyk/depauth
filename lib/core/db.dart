import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'boundaries.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'position.dart';
import 'traversable_entity.dart';
import 'unique_entity.dart';

class Db {
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;

  final Database _db;
  final Map<Position, WeakReference<ValueNotifier<TraversableEntity?>>>
      _entities = {};

  late final ValueNotifier<Boundaries> boundaries = ValueNotifier(
    _getBoundaries(),
  );
  final dependencyChangeNotifier = DependencyChangeNotifier();

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
    select id, name, type
    from entities
    where x = ? and y = ?
  ''');
  late final PreparedStatement _getDependenciesStatement = _db.prepare('''
    select entities.id, name, type
    from entities
    join dependencies
    on entities.id = entity
    where factor = ?
    order by x, y
  ''');
  late final PreparedStatement _getFactorsStatement = _db.prepare('''
    select factors.id
    from factors
    join dependencies
    on factors.id = factor
    join entities
    on entities.id = dependencies.entity
    where factors.entity = ?
    group by factors.id
    order by min(entities.x), min(entities.y)
  ''');
  TraversableEntity? _getEntity(Position position) {
    final entityRow =
        _getEntityStatement.select([position.x, position.y]).firstOrNull;
    return switch (entityRow) {
      null => null,
      Row entityRow => TraversableEntity(
          entityRow['id'] as int,
          entityRow['name'] as String,
          EntityType.values[entityRow['type'] as int],
          _getFactorsStatement.select([entityRow['id']]).map((row) {
            return Factor(
              row['id'] as int,
              _getDependenciesStatement.select([row['id']]).map((row) {
                return UniqueEntity(
                  row['id'] as int,
                  row['name'] as String,
                  EntityType.values[row['type'] as int],
                );
              }),
            );
          }),
        ),
    };
  }

  late final _moveEntityStatement = _db.prepare('''
    update entities
    set x = ?, y = ?
    where x = ? and y = ?
  ''');
  void moveEntity({required Position from, required Position to}) {
    _moveEntityStatement
      ..execute(
        [to.x, to.y, from.x, from.y],
      )
      ..reset();

    _updateEntities([from, to, ..._getDependantPositions(to)]);
    _updateBoundaries();
  }

  late final _deleteEntityStatement = _db.prepare('''
    delete from entities
    where x = ? and y = ?
  ''');
  void deleteEntity(Position position) {
    final dependants = _getDependantPositions(position);

    _deleteEntityStatement
      ..execute([position.x, position.y])
      ..reset();

    _updateEntities([position, ...dependants]);
    _updateBoundaries();
  }

  void createEntity(Position position, Entity entity) {
    _upsertEntity(position, entity);
    _updateEntities([position]);
    _updateBoundaries();
  }

  void changeEntity(Position position, Entity entity) {
    _upsertEntity(position, entity);
    _updateEntities([position, ..._getDependantPositions(position)]);
    _updateDependencies();
  }

  late final _upsertEntityStatement = _db.prepare('''
    insert into entities(name, type, x, y)
    values(?, ?, ?, ?)
    on conflict(x, y)
    do update set name = ?, type = ?
  ''');
  void _upsertEntity(Position position, Entity entity) {
    entity = _getValidEntity(position, entity);
    final type = entity.type.index;

    _upsertEntityStatement
      ..execute([
        entity.name,
        type,
        position.x,
        position.y,
        entity.name,
        type,
      ])
      ..reset();
  }

  Entity _getValidEntity(Position position, Entity entity) {
    entity = Entity(
      entity.name.trim(),
      entity.type,
    );
    final i = _getEntityDuplicateIndex(position, entity);

    if (i > 0) {
      return Entity(
        '${entity.name}$entityDuplicatePrefix$i$entityDuplicateSuffix'.trim(),
        entity.type,
      );
    }

    return entity;
  }

  late final _getEntityDuplicateIndexStatement = _db.prepare('''
    with recursive duplicateIndices(i) as(
      select 0
      union all
      select i + 1
      from duplicateIndices
      join entities
      on name = trim(? || ? || i || ?)
      or i = 0 and name = ?
      where x <> ? or y <> ?
    )
    select max(i)
    from duplicateIndices
  ''');
  int _getEntityDuplicateIndex(Position position, Entity entity) {
    return _getEntityDuplicateIndexStatement
        .select([
          entity.name,
          entityDuplicatePrefix,
          entityDuplicateSuffix,
          entity.name,
          position.x,
          position.y,
        ])
        .first
        .values
        .first as int;
  }

  late final _deleteDependencyStatement = _db.prepare('''
    delete from dependencies
    where entity = ? and factor = ? and exists(
      select factors.id
      from factors
      join entities
      on factors.entity = entities.id
      where x = ? and y = ? and factors.id = ?
    )
  ''');
  void deleteDependency(
    Position position, {
    required int entityId,
    required int factorId,
  }) {
    _deleteDependencyStatement
      ..execute([
        entityId,
        factorId,
        position.x,
        position.y,
        factorId,
      ])
      ..reset();
    _updateEntities([position]);
    _updateDependencies();
  }

  void _updateDependencies() {
    dependencyChangeNotifier._update();
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
    select distinct sources.x, sources.y
    from entities as sources
    join factors
    on sources.id = factors.entity
    join dependencies
    on factor = factors.id
    join entities as targets
    on targets.id = dependencies.entity
    where targets.x = ? and targets.y = ?
  ''');
  Iterable<Position> _getDependantPositions(Position position) =>
      _getDependantPositionsStatement.select([position.x, position.y]).map(
          (row) => Position(row['x'] as int, row['y'] as int));

  Db({
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
  }) : _db = sqlite3.openInMemory() {
    _db.execute('''
      pragma foreign_keys = on;

      create table if not exists entities(
        id integer primary key,
        name text not null,
        type integer not null,
        x integer not null,
        y integer not null
      ) strict;
      create table if not exists factors(
        id integer primary key,
        entity integer not null references entities
      ) strict;
      create table if not exists dependencies(
        id integer primary key,
        factor integer not null references factors,
        entity integer not null references entities
      ) strict;

      create unique index if not exists entity_names on entities(name);
      create unique index if not exists entity_xs_ys on entities(x, y);
      create unique index if not exists dependency_factors_entities
        on dependencies(factor, entity);

      create trigger if not exists after_delete_entity
      after delete on entities begin
        delete from factors where entity = old.oid;
        delete from dependencies where entity = old.oid;
      end;
      create trigger if not exists after_delete_factor
      after delete on factors begin
        delete from dependencies where factor = old.oid;
      end;
      create trigger if not exists before_insert_entity
      before insert on entities begin
        select case new.name
          when trim(new.name) then null
          else raise(rollback, "trailing whitespace")
        end;
      end;
      create trigger if not exists before_update_entity_name
      before update of name on entities begin
        select case new.name
          when trim(new.name) then null
          else raise(rollback, "trailing whitespace")
        end;
      end;
    ''');

    _db.prepare('''
      insert into entities(id, name, type, x, y) values(?, ?, ?, ?, ?)
    ''')
      ..execute([0, 'Google', 1, 1, 1])
      ..execute([1, 'Fastmail', 1, 1, 2])
      ..execute([2, 'Yubikey', 2, 1, 3])
      ..execute([3, 'Nazar', 3, 2, 1])
      ..dispose();

    _db.prepare('''
      insert into factors(id, entity) values(?, ?)
    ''')
      ..execute([0, 0])
      ..execute([1, 1])
      ..execute([2, 0])
      ..execute([3, 1])
      ..dispose();

    _db.prepare('''
      insert into dependencies(factor, entity) values(?, ?)
    ''')
      ..execute([0, 1])
      ..execute([1, 0])
      ..execute([0, 3])
      ..execute([1, 3])
      ..execute([2, 2])
      ..execute([3, 2])
      ..dispose();
  }

  void dispose() => _db.dispose();
}

class DependencyChangeNotifier extends ChangeNotifier {
  void _update() {
    notifyListeners();
  }
}
