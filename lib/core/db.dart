import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'boundaries.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'position.dart';
import 'query.dart';
import 'statement.dart';
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

  late final _entityQuery = Query(_db, '''
    select id, name, type, lost, compromised
    from entities
    where x = ? and y = ?
  ''');
  late final _dependenciesQuery = Query(_db, '''
    select entities.id, name, type, lost, compromised
    from entities
    join dependencies
    on entities.id = entity
    where factor = ?
    order by x, y
  ''');
  late final _factorsQuery = Query(_db, '''
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
    final row = _entityQuery.select([position.x, position.y]).firstOrNull;
    return switch (row) {
      null => null,
      Row row => TraversableEntity(
          Id<Entity>._(row['id'] as int),
          row['name'] as String,
          EntityType.values[row['type'] as int],
          compromised: row['compromised'] as int != 0,
          lost: row['lost'] as int != 0,
          factors: _factorsQuery.select([row['id']]).map((row) {
            return Factor(
              Id._(row['id'] as int),
              _dependenciesQuery.select([row['id']]).map((row) {
                return Entity(
                  Id._(row['id'] as int),
                  row['name'] as String,
                  EntityType.values[row['type'] as int],
                  compromised: row['compromised'] as int != 0,
                  lost: row['lost'] as int != 0,
                );
              }),
            );
          }),
        ),
    };
  }

  late final _moveEntityStatement = Statement(_db, '''
    update entities
    set x = ?, y = ?
    where x = ? and y = ?
  ''');
  void moveEntity({required Position from, required Position to}) {
    _moveEntityStatement.execute([to.x, to.y, from.x, from.y]);
    _updateEntities([from, to, ..._getDependantPositions(to)]);
    _updateBoundaries();
  }

  late final _deleteEntityStatement = Statement(_db, '''
    delete from entities
    where x = ? and y = ?
  ''');
  void deleteEntity(Position position) {
    final dependants = _getDependantPositions(position);

    _deleteEntityStatement.execute([position.x, position.y]);
    _updateEntities([position, ...dependants]);
    _updateBoundaries();
  }

  late final _createEntityStatement = Statement(_db, '''
    insert into entities(name, type, x, y, lost, compromised)
    values(?, 0, ?, ?, false, false)
  ''');
  void createEntity(Position position, String name) {
    _createEntityStatement.execute([
      _getValidName(position, name),
      position.x,
      position.y,
    ]);
    _updateEntities([position]);
    _updateBoundaries();
  }

  late final _changeNameStatement = Statement(_db, '''
    update entities
    set name = ?
    where x = ? and y = ?
  ''');
  void changeName(Position position, String name) {
    _changeNameStatement.execute([
      _getValidName(position, name),
      position.x,
      position.y,
    ]);
    _updateEntities([position, ..._getDependantPositions(position)]);
  }

  late final _changeTypeStatement = Statement(_db, '''
    update entities
    set type = ?
    where x = ? and y = ?
  ''');
  void changeType(Position position, EntityType type) {
    _changeTypeStatement.execute([
      type.index,
      position.x,
      position.y,
    ]);
    _updateEntities([position, ..._getDependantPositions(position)]);
    _updateDependencies();
  }

  late final _toggleCompromisedStatement = Statement(_db, '''
    update entities
    set compromised = ?
    where x = ? and y = ?
  ''');
  void toggleCompromised(Position position, bool value) {
    _toggleCompromisedStatement.execute([
      value ? 1 : 0,
      position.x,
      position.y,
    ]);
    _updateEntities([position]);
  }

  late final _toggleLostStatement = Statement(_db, '''
    update entities
    set lost = ?
    where x = ? and y = ?
  ''');
  void toggleLost(Position position, bool value) {
    _toggleLostStatement.execute([
      value ? 1 : 0,
      position.x,
      position.y,
    ]);
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

  late final _entityDuplicateIndexQuery = Query(_db, '''
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
    return _entityDuplicateIndexQuery
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

  late final _addDependencyStatement = Statement(_db, '''
    insert or ignore into dependencies(entity, factor) values(?, ?)
  ''');
  void addDependency(
    Position position,
    Id<Factor> factorId,
    Id<Entity> entityId,
  ) {
    assert(_getPositionOfFactor(factorId) == position);
    _addDependencyStatement.execute([entityId._value, factorId._value]);
    _updateEntities([position]);
    _updateDependencies();
  }

  late final _removeDependencyStatement = Statement(_db, '''
    delete from dependencies
    where entity = ? and factor = ?
  ''');
  void removeDependency(
    Position position,
    Id<Factor> factorId,
    Id<Entity> entityId,
  ) {
    assert(_getPositionOfFactor(factorId) == position);
    _removeDependencyStatement.execute([entityId._value, factorId._value]);
    _updateEntities([position]);
    _updateDependencies();
  }

  late final _addFactorStatement = Statement(_db, '''
    insert into factors(entity) values(?)
  ''');
  void addFactor(Position position, Id<Entity> entityId) {
    assert(_getEntity(position)?.id == entityId);
    _addFactorStatement.execute([entityId._value]);
    _updateEntities([position]);
  }

  late final _removeFactorStatement = Statement(_db, '''
    delete from factors where id = ?
  ''');
  void removeFactor(Position position, Id<Factor> factorId) {
    assert(_getPositionOfFactor(factorId) == position);
    _removeFactorStatement.execute([factorId._value]);
    _updateEntities([position]);
    _updateDependencies();
  }

  late final _positionOfFactorQuery = Query(_db, '''
    select x, y
    from entities
    join factors
    on entities.id = entity
    where factors.id = ?
  ''');
  Position? _getPositionOfFactor(Id<Factor> id) {
    final row = _positionOfFactorQuery.select([id._value]).firstOrNull;

    return switch (row) {
      null => null,
      Row row => Position(row['x'] as int, row['y'] as int),
    };
  }

  late final _boundariesQuery = Query(_db, '''
    select min(x) - 1, min(y) - 1, max(x) + 1, max(y) + 1
    from entities
  ''');
  Boundaries _getBoundaries() {
    final values = _boundariesQuery.select().first.values;
    return Boundaries(
      Position(values[0] as int? ?? 0, values[1] as int? ?? 0),
      Position(values[2] as int? ?? 0, values[3] as int? ?? 0),
    );
  }

  late final _dependantPositionsQuery = Query(_db, '''
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
      _dependantPositionsQuery.select([position.x, position.y]).map(
          (row) => Position(row['x'] as int, row['y'] as int));

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
        lost integer not null,
        compromised integer not null
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
        delete from factors where entity = old.id;
        delete from dependencies where entity = old.id;
      end;
      create trigger if not exists after_delete_factor
      after delete on factors begin
        delete from dependencies where factor = old.id;
      end;
      create trigger if not exists before_insert_entity
      before insert on entities begin
        select case new.name
          when trim(new.name) then null
          else raise(rollback, 'trailing whitespace')
        end;
      end;
      create trigger if not exists before_update_entity_name
      before update of name on entities begin
        select case new.name
          when trim(new.name) then null
          else raise(rollback, 'trailing whitespace')
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
