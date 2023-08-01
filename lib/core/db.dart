import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'boundaries.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'position.dart';
import 'traversable_entity.dart';

class Db {
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;

  final Database _db;
  final Map<Position, WeakReference<ValueNotifier<TraversableEntity?>>>
      _entities = {};

  late final ValueNotifier<Boundaries> boundaries = ValueNotifier(
    _getBoundaries(),
  );
  final dependencyChangeNotifier = _DependencyChangeNotifier();

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
    select id, name, type, lost, compromised
    from entities
    where x = ? and y = ?
  ''');
  late final PreparedStatement _getDependenciesStatement = _db.prepare('''
    select entities.id, name, type, lost, compromised
    from entities
    join dependencies
    on entities.id = entity
    where factor = ?
    order by x, y
  ''');
  late final PreparedStatement _getFactorsStatement = _db.prepare('''
    select factors.id
    from factors
    left join dependencies
    on factors.id = factor
    left join entities
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
          Id<Entity>._(entityRow['id'] as int),
          entityRow['name'] as String,
          EntityType.values[entityRow['type'] as int],
          compromised: entityRow['compromised'] as int != 0,
          lost: entityRow['lost'] as int != 0,
          factors: _getFactorsStatement.select([entityRow['id']]).map((row) {
            return Factor(
              Id._(row['id'] as int),
              _getDependenciesStatement.select([row['id']]).map((row) {
                return Entity(
                  Id._(row['id'] as int),
                  row['name'] as String,
                  EntityType.values[row['type'] as int],
                  lost: row['lost'] as int != 0,
                  compromised: row['compromised'] as int != 0,
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

  late final _createEntityStatement = _db.prepare('''
    insert into entities(name, type, x, y, lost, compromised)
    values(?, 0, ?, ?, 0, 0)
  ''');
  void createEntity(Position position, String name) {
    _createEntityStatement
      ..execute([
        _getValidName(position, name),
        position.x,
        position.y,
      ])
      ..reset();
    _updateEntities([position]);
    _updateBoundaries();
  }

  late final _changeNameStatement = _db.prepare('''
    update entities
    set name = ?
    where x = ? and y = ?
  ''');
  void changeName(Position position, String name) {
    _changeNameStatement
      ..execute([
        _getValidName(position, name),
        position.x,
        position.y,
      ])
      ..reset();
    _updateEntities([position, ..._getDependantPositions(position)]);
  }

  late final _changeTypeStatement = _db.prepare('''
    update entities
    set type = ?
    where x = ? and y = ?
  ''');
  void changeType(Position position, EntityType type) {
    _changeTypeStatement
      ..execute([
        type.index,
        position.x,
        position.y,
      ])
      ..reset();
    _updateEntities([position, ..._getDependantPositions(position)]);
    _updateDependencies();
  }

  late final _toggleCompromisedStatement = _db.prepare('''
    update entities
    set compromised = ?
    where x = ? and y =?
  ''');
  void toggleCompromised(Position position, bool value) {
    _toggleCompromisedStatement
      ..execute([
        value ? 1 : 0,
        position.x,
        position.y,
      ])
      ..reset();
    _updateEntities([position]);
  }

  late final _toggleLostStatement = _db.prepare('''
    update entities
    set lost = ?
    where x = ? and y = ?
  ''');
  void toggleLost(Position position, bool value) {
    _toggleLostStatement
      ..execute([
        value ? 1 : 0,
        position.x,
        position.y,
      ])
      ..reset();
    _updateEntities([position]);
  }

  String _getValidName(Position position, String name) {
    name = name.trim();
    final i = _getEntityDuplicateIndex(position, name);

    if (i > 0) {
      return '$name$entityDuplicatePrefix$i$entityDuplicateSuffix'.trim();
    }

    return name;
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
  int _getEntityDuplicateIndex(Position position, String name) {
    return _getEntityDuplicateIndexStatement
        .select([
          name,
          entityDuplicatePrefix,
          entityDuplicateSuffix,
          name,
          position.x,
          position.y,
        ])
        .first
        .values
        .first as int;
  }

  late final _addDependencyStatement = _db.prepare('''
    insert or ignore into dependencies(entity, factor) values(?, ?)
  ''');
  void addDependency(
    Position position,
    Id<Factor> factorId,
    Id<Entity> entityId,
  ) {
    assert(_getPositionOfFactor(factorId) == position);
    _addDependencyStatement
      ..execute([entityId._value, factorId._value])
      ..reset();
    _updateEntities([position]);
    _updateDependencies();
  }

  late final _removeDependencyStatement = _db.prepare('''
    delete from dependencies
    where entity = ? and factor = ?
  ''');
  void removeDependency(
    Position position,
    Id<Factor> factorId,
    Id<Entity> entityId,
  ) {
    assert(_getPositionOfFactor(factorId) == position);
    _removeDependencyStatement
      ..execute([entityId._value, factorId._value])
      ..reset();
    _updateEntities([position]);
    _updateDependencies();
  }

  late final _addFactorStatement = _db.prepare('''
    insert into factors(entity) values(?)
  ''');
  void addFactor(Position position, Id<Entity> entityId) {
    assert(_getEntity(position)?.id == entityId);
    _addFactorStatement
      ..execute([entityId._value])
      ..reset();
    _updateEntities([position]);
  }

  late final _removeFactorStatement = _db.prepare('''
    delete from factors where id = ?
  ''');
  void removeFactor(Position position, Id<Factor> factorId) {
    assert(_getPositionOfFactor(factorId) == position);
    _removeFactorStatement
      ..execute([factorId._value])
      ..reset();
    _updateEntities([position]);
    _updateDependencies();
  }

  late final _getPositionOfFactorStatement = _db.prepare('''
    select x, y
    from entities
    join factors
    on entities.id = entity
    where factors.id = ?
  ''');
  Position? _getPositionOfFactor(Id<Factor> id) {
    final row = _getPositionOfFactorStatement.select([id._value]).firstOrNull;

    return switch (row) {
      null => null,
      Row row => Position(row['x'] as int, row['y'] as int),
    };
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

  Db(
    String path, {
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
  }) : _db = sqlite3.open(path) {
    _db.execute('''
      pragma foreign_keys = on;

      create table if not exists entities(
        id integer primary key,
        name text not null,
        type integer not null,
        x integer not null,
        y integer not null,
        lost int not null,
        compromised int not null
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
  }

  void dispose() => _db.dispose();
}

class Id<T> {
  final int _value;
  const Id._(this._value);

  @override
  bool operator ==(Object other) => other is Id<T> && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

class _DependencyChangeNotifier extends ChangeNotifier {
  void _update() {
    notifyListeners();
  }
}
