import 'package:sqlite3/sqlite3.dart';

import 'active_record_storage.dart';
import 'boundaries.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'position.dart';
import 'query.dart';
import 'statement.dart';
import 'tracked_disposal_storage.dart';
import 'traversable_entity.dart';

class Storage extends TrackedDisposalStorage implements ActiveRecordStorage {
  final Database _database;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;

  late final _entityQuery = Query(_database, '''
    select identity, name, type, lost, compromised, importance
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
    final row = _entityQuery.select([position.x, position.y]).firstOrNull;

    switch (row) {
      case null:
        return null;

      case Row row:
        final [identity, name, type, lost, compromised, importance] =
            row.values;

        return TraversableEntity(
          Passport._(
            Identity._(identity as int),
            position,
          ),
          name as String,
          EntityType.values[type as int],
          lost: lost as int != 0,
          compromised: compromised as int != 0,
          importance: importance as int,
          factors: _factorsQuery.select([identity]).map((row) {
            final [factorIdentity] = row.values;

            return Factor(
              FactorPassport._(
                Identity._(factorIdentity as int),
                Passport._(
                  Identity._(identity),
                  position,
                ),
              ),
              _dependenciesQuery.select([factorIdentity]).map((row) {
                final [identity, name, type] = row.values;

                return Entity(
                  Identity._(identity as int),
                  name as String,
                  EntityType.values[type as int],
                );
              }),
            );
          }),
        );
    }
  }

  late final _moveEntityStatement = Statement(_database, '''
    update entities
    set x = ?, y = ?
    where x = ? and y = ?
  ''');
  void moveEntity(Passport entity, Position position) {
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
  void deleteEntity(Passport entity) {
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
      type.index,
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

  late final _addDependencyStatement = Statement(_database, '''
    insert or ignore into dependencies(entity, factor) values(?, ?)
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
  removeDependency(factor, entity) {
    _removeDependencyStatement.execute([
      entity._value,
      factor.identity._value,
    ]);
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

  late final _addDependencyAsFactorStatement = Statement(_database, '''
    insert into dependencies(entity, factor) values(?, last_insert_rowid())
  ''');
  @override
  addDependencyAsFactor(entity, dependency) {
    _addFactorStatement.execute([entity.identity._value]);
    _addDependencyAsFactorStatement.execute([dependency._value]);
  }

  late final _factorIdentitiesQuery = Query(_database, '''
    select identity
    from factors
    where entity = ?
  ''');
  Iterable<Identity<Factor>> getFactors(Identity<Entity> entity) {
    return _factorIdentitiesQuery.select([entity._value]).map(_parseIdentity);
  }

  late final _dependencyEntitiesQuery = Query(_database, '''
    select entity
    from dependencies
    join entities
    on entity = entities.identity
    where factor = ?
  ''');
  Iterable<Identity<Entity>> getDependencies(Identity<Factor> factor) {
    return _dependencyEntitiesQuery.select([factor._value]).map(_parseIdentity);
  }

  late final _dependantsQuery = Query(_database, '''
    select distinct factors.entity
    from factors
    join dependencies
    on factors.identity = factor
    where dependencies.entity = ?
  ''');
  Iterable<Identity<Entity>> getDependants(Identity<Entity> entity) {
    return _dependantsQuery.select([entity._value]).map(_parseIdentity);
  }

  late final _boundariesQuery = Query(_database, '''
    select min(x) - 1, min(y) - 1, max(x) + 1, max(y) + 1
    from entities
  ''');
  Boundaries get boundaries {
    final [minX, minY, maxX, maxY] = _boundariesQuery.select().first.values;

    return Boundaries(
      Position(minX as int? ?? 0, minY as int? ?? 0),
      Position(maxX as int? ?? 0, maxY as int? ?? 0),
    );
  }

  late final _dependantPositionsQuery = Query(_database, '''
    select distinct sources.x, sources.y
    from entities as sources
    join factors
    on sources.identity = factors.entity
    join dependencies
    on factor = factors.identity
    join entities as targets
    on targets.identity = dependencies.entity
    where targets.x = ? and targets.y = ?
  ''');
  Iterable<Position> getDependantPositions(Position position) {
    return _dependantPositionsQuery
        .select([position.x, position.y]).map(_parsePosition);
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

  late final _normalEntitiesQuery = Query(_database, '''
    select identity
    from entities
    where not lost and not compromised
  ''');
  Iterable<Identity<Entity>> get normalEntities {
    return _normalEntitiesQuery.select().map(_parseIdentity);
  }

  late final _lostEntititesQuery = Query(_database, '''
    select identity
    from entities
    where lost
  ''');
  Iterable<Identity<Entity>> get lostEntities {
    return _lostEntititesQuery.select().map(_parseIdentity);
  }

  late final _compromisedEntititesQuery = Query(_database, '''
    select identity
    from entities
    where compromised
  ''');
  Iterable<Identity<Entity>> get compromisedEntities {
    return _compromisedEntititesQuery.select().map(_parseIdentity);
  }

  late final _lostPositionsQuery = Query(_database, '''
    select x, y
    from entities
    where lost
  ''');
  Iterable<Position> get lostPositions {
    return _lostPositionsQuery.select().map(_parsePosition);
  }

  late final _compromisedPositionsQuery = Query(_database, '''
    select x, y
    from entities
    where compromised
  ''');
  Iterable<Position> get compromisedPositions {
    return _compromisedPositionsQuery.select().map(_parsePosition);
  }

  late final _entityCountQuery = Query(_database, '''
    select count(true)
    from entities
  ''');
  int get entityCount => _entityCountQuery.select().first.values.first as int;

  Position _parsePosition(Row row) {
    final [x, y] = row.values;

    return Position(x as int, y as int);
  }

  Identity<T> _parseIdentity<T>(Row row) {
    return Identity._(row.values.first as int);
  }

  late final _nameQuery = Query(_database, '''
    select name from meta
  ''');
  String get name {
    return _nameQuery.select().first.values.first as String;
  }

  late final _setNameStatement = Statement(_database, '''
    update meta set name = ?
  ''');
  set name(String value) {
    _setNameStatement.execute([value]);
  }

  Stream<double> copy(String path) async* {
    final copy = sqlite3.open(path);

    yield* _database.backup(copy);

    copy.execute('''
      delete from meta
    ''');
    copy.dispose();
  }

  Storage({
    required String path,
    required String name,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
  }) : _database = sqlite3.open(path) {
    _database.execute('''
      pragma application_id = 1147498561;
      pragma foreign_keys = true;
      pragma auto_vacuum = full;
      pragma cache_size = -100000;
      pragma encoding = 'UTF-8';
      pragma locking_mode = exclusive;
      pragma synchronous = full;
      pragma user_version = 1;

      create table if not exists meta(
        identity integer primary key,
        name text not null
      ) strict, without rowid;
      create table if not exists entities(
        identity integer primary key,
        name text not null,
        type integer not null,
        x integer not null,
        y integer not null,
        lost integer not null,
        compromised integer not null,
        importance integer not null
      ) strict;
      create table if not exists factors(
        identity integer primary key,
        entity integer not null references entities
      ) strict;
      create table if not exists dependencies(
        identity integer primary key,
        factor integer not null references factors,
        entity integer not null references entities
      ) strict;

      create unique index if not exists entity_names on entities(name);
      create unique index if not exists entity_xs_ys on entities(x, y);
      create unique index if not exists dependency_factors_entities
        on dependencies(factor, entity);

      create index if not exists entity_ys on entities(y);

      create trigger if not exists after_delete_entity
      after delete on entities begin
        delete from factors where entity = old.identity;
        delete from dependencies where entity = old.identity;
      end;
      create trigger if not exists after_delete_factor
      after delete on factors begin
        delete from dependencies where factor = old.identity;
      end;
    ''');

    _database.execute('''
      insert or ignore
      into meta(identity, name)
      values(0, ?)
    ''', [name]);
  }

  @override
  dispose() {
    _database.dispose();
    super.dispose();
  }
}

class FactorPassport {
  final Identity<Factor> identity;
  final Passport entity;

  const FactorPassport._(this.identity, this.entity);
}

class Passport {
  final Identity<Entity> identity;
  final Position position;

  const Passport._(this.identity, this.position);
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
