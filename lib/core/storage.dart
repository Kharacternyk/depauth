import 'package:sqlite3/sqlite3.dart';

import 'active_record.dart';
import 'boundaries.dart';
import 'dependency.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'passportless_entity.dart';
import 'position.dart';
import 'query.dart';
import 'statement.dart';
import 'storage_schema.dart';
import 'tracked_disposal.dart';
import 'traversable_entity.dart';

class Storage extends TrackedDisposal implements ActiveRecord {
  final Database _database;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;

  Storage({
    required String path,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
  }) : _database = sqlite3.open(path)..applyStorageSchema();

  @override
  dispose() {
    _database.dispose();
    super.dispose();
  }

  late final _entityQuery = Query(_database, '''
    select identity, name, type
    from entities
    where x = ? and y = ?
  ''');
  late final _dependenciesQuery = Query(_database, '''
    select entities.identity, name, type
    from entities
    join dependencies
    on entities.identity = entity
    where factor = ?
    order by x, y
  ''');
  late final _factorsQuery = Query(_database, '''
    select factors.identity
    from factors
    left join dependencies
    on factors.identity = factor
    left join entities
    on entities.identity = dependencies.entity
    where factors.entity = ?
    group by factors.identity
    order by min(entities.x), min(entities.y)
  ''');
  TraversableEntity? getEntity(Position position) {
    final values = _entityQuery.selectOne([position.x, position.y]);

    switch (values) {
      case null:
        return null;

      case Values values:
        final [identity, name, type] = values;
        final passport = EntityPassport._(
          Identity._(identity as int),
          position,
        );

        return TraversableEntity(
          passport,
          name as String,
          EntityType(type as int),
          _factorsQuery.select([identity], (values) {
            final [factorIdentity] = values;
            final factorPassport = FactorPassport._(
              Identity._(factorIdentity as int),
              passport,
            );

            return Factor(
              factorPassport,
              _dependenciesQuery.select([factorIdentity], (values) {
                final [identity, name, type] = values;

                return Dependency(
                  DependencyPassport._(
                    Identity._(identity as int),
                    factorPassport,
                  ),
                  name as String,
                  EntityType(type as int),
                );
              }),
            );
          }),
        );
    }
  }

  late final _passportlessEntityQuery = Query(_database, '''
    select name, type
    from entities
    where identity = ?
  ''');
  @override
  getPassportlessEntity(identity) {
    final values = _passportlessEntityQuery.selectOne([identity._value]);

    if (values == null) {
      return null;
    }

    final [name, type] = values;

    return PassportlessEntity(
      identity,
      name as String,
      EntityType(type as int),
    );
  }

  late final _moveEntityStatement = Statement(_database, '''
    update entities
    set x = ?, y = ?
    where x = ? and y = ?
  ''');
  void moveEntity(EntityPassport entity, Position position) {
    _moveEntityStatement.execute([
      position.x,
      position.y,
      entity.position.x,
      entity.position.y,
    ]);
  }

  late final _deleteEntityStatement = Statement(_database, '''
    delete from entities
    where x = ? and y = ?
  ''');
  void deleteEntity(EntityPassport entity) {
    _deleteEntityStatement.execute([entity.position.x, entity.position.y]);
  }

  late final _createEntityStatement = Statement(_database, '''
    insert into entities(name, type, x, y, lost, compromised, importance)
    values(?, 0, ?, ?, false, false, 0)
  ''');
  void createEntity(Position position, String name) {
    _createEntityStatement.execute([
      _getValidName(position, name),
      position.x,
      position.y,
    ]);
  }

  late final _changeNameStatement = Statement(_database, '''
    update entities
    set name = ?
    where x = ? and y = ?
  ''');
  @override
  changeName(entity, name) {
    _changeNameStatement.execute([
      _getValidName(entity.position, name),
      entity.position.x,
      entity.position.y,
    ]);
  }

  late final _changeTypeStatement = Statement(_database, '''
    update entities
    set type = ?
    where x = ? and y = ?
  ''');
  @override
  changeType(entity, type) {
    _changeTypeStatement.execute([
      type.value,
      entity.position.x,
      entity.position.y,
    ]);
  }

  late final _changeImportanceStatement = Statement(_database, '''
    update entities
    set importance = ?
    where x = ? and y = ?
  ''');
  @override
  changeImportance(entity, value) {
    _changeImportanceStatement.execute([
      value,
      entity.position.x,
      entity.position.y,
    ]);
  }

  late final _toggleCompromisedStatement = Statement(_database, '''
    update entities
    set compromised = ?
    where x = ? and y = ?
  ''');
  @override
  toggleCompromised(entity, value) {
    _toggleCompromisedStatement.execute([
      value ? 1 : 0,
      entity.position.x,
      entity.position.y,
    ]);
  }

  late final _toggleLostStatement = Statement(_database, '''
    update entities
    set lost = ?
    where x = ? and y = ?
  ''');
  @override
  toggleLost(entity, value) {
    _toggleLostStatement.execute([
      value ? 1 : 0,
      entity.position.x,
      entity.position.y,
    ]);
  }

  String _getValidName(Position position, String name) {
    name = name.trim();
    final i = _getEntityDuplicateIndex(position, name);

    if (i > 0) {
      return [
        name,
        entityDuplicatePrefix,
        i,
        entityDuplicateSuffix,
      ].join().trim();
    }

    return name;
  }

  late final _entityDuplicateIndexQuery = Query(_database, '''
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
    return _entityDuplicateIndexQuery.selectOne([
      name,
      entityDuplicatePrefix,
      entityDuplicateSuffix,
      name,
      position.x,
      position.y,
    ])?.first as int;
  }

  late final _addDependencyStatement = Statement(_database, '''
    insert into dependencies(entity, factor) values(?, ?)
  ''');
  @override
  addDependency(factor, entity) {
    _addDependencyStatement.execute([
      entity._value,
      factor.identity._value,
    ]);
  }

  late final _removeDependencyStatement = Statement(_database, '''
    delete from dependencies
    where entity = ? and factor = ?
  ''');
  @override
  removeDependency(dependency) {
    _removeDependencyStatement.execute([
      dependency.identity._value,
      dependency.factor.identity._value,
    ]);
  }

  late final _moveDependencyStatement = Statement(_database, '''
    update dependencies
    set factor = ?
    where factor = ? and entity = ?
  ''');
  @override
  moveDependency(DependencyPassport dependency, FactorPassport factor) {
    _moveDependencyStatement.execute([
      factor.identity._value,
      dependency.factor.identity._value,
      dependency.identity._value,
    ]);
  }

  late final _moveDependencyAsFactorStatement = Statement(_database, '''
    update dependencies
    set factor = last_insert_rowid()
    where factor = ? and entity = ?
  ''');
  @override
  moveDependencyAsFactor(dependency, entity) {
    _begin.execute();
    _addFactorStatement.execute([entity.identity._value]);
    _moveDependencyAsFactorStatement.execute([
      dependency.factor.identity._value,
      dependency.identity._value,
    ]);
    _commit.execute();
  }

  late final _addFactorStatement = Statement(_database, '''
    insert into factors(entity) values(?)
  ''');
  @override
  addFactor(entity) {
    _addFactorStatement.execute([entity.identity._value]);
  }

  late final _removeFactorStatement = Statement(_database, '''
    delete from factors where identity = ?
  ''');
  void removeFactor(FactorPassport factor) {
    _removeFactorStatement.execute([factor.identity._value]);
  }

  late final _mergeFactorsStatement = Statement(_database, '''
    update or ignore dependencies
    set factor = ?
    where factor = ?
  ''');
  @override
  mergeFactors(into, from) {
    _begin.execute();
    _mergeFactorsStatement.execute([
      into.identity._value,
      from.identity._value,
    ]);
    _removeFactorStatement.execute([from.identity._value]);
    _commit.execute();
  }

  late final _addDependencyAsFactorStatement = Statement(_database, '''
    insert into dependencies(entity, factor) values(?, last_insert_rowid())
  ''');
  @override
  addDependencyAsFactor(entity, dependency) {
    _begin.execute();
    _addFactorStatement.execute([entity.identity._value]);
    _addDependencyAsFactorStatement.execute([dependency._value]);
    _commit.execute();
  }

  late final _factorIdentitiesQuery = Query(_database, '''
    select identity
    from factors
    where entity = ?
  ''');
  Iterable<Identity<Factor>> getFactors(Identity<Entity> entity) {
    return _factorIdentitiesQuery.select([entity._value], _parseIdentity);
  }

  late final _dependencyEntitiesQuery = Query(_database, '''
    select entity
    from dependencies
    join entities
    on entity = entities.identity
    where factor = ?
  ''');
  Iterable<Identity<Entity>> getDependencies(Identity<Factor> factor) {
    return _dependencyEntitiesQuery.select([factor._value], _parseIdentity);
  }

  late final _distinctDependenciesQuery = Query(_database, '''
    select distinct dependencies.entity
    from factors
    join dependencies
    on factors.identity = factor
    where factors.entity = ?
  ''');
  Iterable<Identity<Entity>> getDistinctDependencies(Identity<Entity> entity) {
    return _distinctDependenciesQuery.select([entity._value], _parseIdentity);
  }

  late final _dependantsQuery = Query(_database, '''
    select distinct factors.entity
    from factors
    join dependencies
    on factors.identity = factor
    where dependencies.entity = ?
  ''');
  Iterable<Identity<Entity>> getDependants(Identity<Entity> entity) {
    return _dependantsQuery.select([entity._value], _parseIdentity);
  }

  late final _boundariesQuery = Query(_database, '''
    select min(x) - 1, min(y) - 1, max(x) + 1, max(y) + 1
    from entities
  ''');
  Boundaries get boundaries {
    final [minX, minY, maxX, maxY] = _boundariesQuery.selectOne()!;

    return Boundaries(
      Position(minX as int? ?? 0, minY as int? ?? 0),
      Position(maxX as int? ?? 0, maxY as int? ?? 0),
    );
  }

  late final _dependantPositionsQuery = Query(_database, '''
    select distinct x, y
    from entities
    join factors
    on entities.identity = factors.entity
    join dependencies
    on factor = factors.identity
    where dependencies.entity = ?
  ''');
  Iterable<Position> getDependantPositions(Identity<Entity> entity) {
    return _dependantPositionsQuery.select([entity._value], _parsePosition);
  }

  late final _resetLossStatement = Statement(_database, '''
    update entities
    set lost = false
  ''');
  void resetLoss() => _resetLossStatement.execute();

  late final _resetCompromiseStatement = Statement(_database, '''
    update entities
    set compromised = false
  ''');
  void resetCompromise() => _resetCompromiseStatement.execute();

  late final _lostEntititesQuery = Query(_database, '''
    select identity
    from entities
    where lost
  ''');
  Iterable<Identity<Entity>> get lostEntities {
    return _lostEntititesQuery.select(null, _parseIdentity);
  }

  late final _compromisedEntititesQuery = Query(_database, '''
    select identity
    from entities
    where compromised
  ''');
  Iterable<Identity<Entity>> get compromisedEntities {
    return _compromisedEntititesQuery.select(null, _parseIdentity);
  }

  late final _positiveImportanceQuery = Query(_database, '''
    select identity, importance
    from entities
    where importance > 0
  ''');
  Iterable<(Identity<Entity>, int)> get positiveImportance {
    return _positiveImportanceQuery.select(null, (values) {
      final [identity, importance] = values;

      return (Identity._(identity as int), importance as int);
    });
  }

  late final _entityCountQuery = Query(_database, '''
    select count(true)
    from entities
  ''');
  int get entityCount => _entityCountQuery.selectOne()?.first as int;

  late final _begin = Statement(_database, '''
    begin immediate
  ''');
  late final _commit = Statement(_database, '''
    commit
  ''');

  Position _parsePosition(Values values) {
    final [x, y] = values;

    return Position(x as int, y as int);
  }

  Identity<T> _parseIdentity<T>(Values values) {
    return Identity._(values.first as int);
  }

  Stream<double> copy(String path) async* {
    final copy = sqlite3.open(path);

    yield* _database.backup(copy);

    copy.dispose();
  }
}

class DependencyPassport {
  final Identity<Entity> identity;
  final FactorPassport factor;

  const DependencyPassport._(this.identity, this.factor);
}

class FactorPassport {
  final Identity<Factor> identity;
  final EntityPassport entity;

  const FactorPassport._(this.identity, this.entity);
}

class EntityPassport {
  final Identity<Entity> identity;
  final Position position;

  const EntityPassport._(this.identity, this.position);
}

class Identity<T> {
  final int _value;

  const Identity._(this._value);

  @override
  operator ==(other) => other is Identity<T> && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  toString() => _value.toString();
}
