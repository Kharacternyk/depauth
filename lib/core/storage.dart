import 'package:sqlite3/sqlite3.dart';

import 'active_record.dart';
import 'boundaries.dart';
import 'dependency.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'packed_integer_pair.dart';
import 'passportless_entity.dart';
import 'position.dart';
import 'query.dart';
import 'statement.dart';
import 'storage.pb.dart' as proto;
import 'storage_schema.dart';
import 'storage_slot.dart';
import 'tracked_disposal.dart';
import 'traversable_entity.dart';

class Storage extends TrackedDisposal implements ActiveRecord, StorageSlot {
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
    select entities.identity, name, type, text
    from entities
    left join notes
    on entities.identity = entity
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
        final [identity, name, type, note] = values;
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
          note as String?,
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
    where identity = ?
  ''');
  void moveEntity(EntityPassport entity, Position position) {
    _moveEntityStatement.execute([
      position.x,
      position.y,
      entity.identity._value,
    ]);
  }

  late final _deleteEntityStatement = Statement(_database, '''
    delete from entities
    where identity = ?
  ''');
  void deleteEntity(EntityPassport entity) {
    _deleteEntityStatement.execute([entity.identity._value]);
  }

  late final _createEntityStatement = Statement(_database, '''
    insert into entities(name, type, x, y, lost, compromised, importance)
    values(?, 0, ?, ?, false, false, 0)
  ''');
  void createEntity(Position position, String name) {
    _createEntityStatement.execute([
      _getValidName(name),
      position.x,
      position.y,
    ]);
  }

  late final _changeNameStatement = Statement(_database, '''
    update entities
    set name = ?
    where identity = ?
  ''');
  @override
  changeName(entity, name) {
    _changeNameStatement.execute([
      _getValidName(name, entity.identity),
      entity.identity._value,
    ]);
  }

  late final _changeTypeStatement = Statement(_database, '''
    update entities
    set type = ?
    where identity = ?
  ''');
  @override
  changeType(entity, type) {
    _changeTypeStatement.execute([type.value, entity.identity._value]);
  }

  late final _createNoteStatement = Statement(_database, '''
    insert or ignore
    into notes(entity, text)
    values(?, ?)
  ''');
  @override
  createNote(entity, note) {
    _createNoteStatement.execute([entity.identity._value, note]);
  }

  late final _changeNoteStatement = Statement(_database, '''
    update notes
    set text = ?
    where entity = ?
  ''');
  @override
  changeNote(entity, note) {
    _changeNoteStatement.execute([note, entity.identity._value]);
  }

  late final _deleteNoteStatement = Statement(_database, '''
    delete from notes
    where entity = ?
  ''');
  @override
  deleteNote(entity) {
    _deleteNoteStatement.execute([entity.identity._value]);
  }

  late final _changeImportanceStatement = Statement(_database, '''
    update entities
    set importance = ?
    where identity = ?
  ''');
  @override
  changeImportance(entity, value) {
    _changeImportanceStatement.execute([value, entity.identity._value]);
  }

  late final _toggleCompromisedStatement = Statement(_database, '''
    update entities
    set compromised = ?
    where identity = ?
  ''');
  @override
  toggleCompromised(entity, value) {
    _toggleCompromisedStatement.execute([
      value ? 1 : 0,
      entity.identity._value,
    ]);
  }

  late final _toggleLostStatement = Statement(_database, '''
    update entities
    set lost = ?
    where identity = ?
  ''');
  @override
  toggleLost(entity, value) {
    _toggleLostStatement.execute([value ? 1 : 0, entity.identity._value]);
  }

  String _getValidName(String name, [Identity<Entity>? entity]) {
    name = name.trim();
    final i = _getEntityDuplicateIndex(name, entity);

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
      where identity <> ? or ? is null
    )
    select max(i)
    from duplicateIndices
  ''');
  int _getEntityDuplicateIndex(String name, [Identity<Entity>? entity]) {
    return _entityDuplicateIndexQuery.selectOne([
      name,
      entityDuplicatePrefix,
      entityDuplicateSuffix,
      name,
      entity?._value,
      entity?._value,
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

  late final _notedEntitiesQuery = Query(_database, '''
    select entity from notes
  ''');
  Iterable<Identity<Entity>> get notedEntities =>
      _notedEntitiesQuery.select(null, _parseIdentity);

  late final _entityCountQuery = Query(_database, '''
    select count(true) from entities
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

  late final _insertEntityStatment = Statement(_database, '''
    insert into entities(identity, name, type, x, y, lost, compromised, importance)
    values(?, ?, ?, ?, ?, ?, ?, ?)
  ''');
  late final _insertFactorStatement = Statement(_database, '''
    insert into factors(identity, entity)
    values(?, ?)
  ''');
  late final _insertDependencyStatement = Statement(_database, '''
    insert or ignore
    into dependencies(factor, entity)
    values(?, ?)
  ''');
  late final _insertNoteStatement = Statement(_database, '''
    insert or ignore
    into notes(entity, text)
    values(?, ?)
  ''');
  late final _entityIdentityOffsetQuery = Query(_database, '''
    select max(identity) from entities
  ''');
  late final _factorIdentityOffsetQuery = Query(_database, '''
    select max(identity) from factors
  ''');
  @override
  import(storage) {
    final origin = boundaries.end;
    final entityIdentityOffset =
        (_entityIdentityOffsetQuery.selectOne()?.first as int? ?? 0) + 1;
    final factorIdentityOffset =
        (_factorIdentityOffsetQuery.selectOne()?.first as int? ?? 0) + 1;

    _begin.execute();
    storage.positions.forEach((position, identity) {
      final pair = PackedIntegerPair.fromPacked(position);
      final (x, y) = (pair.first + origin.x, pair.second + origin.y);
      final entity = storage.entities[identity];

      if (entity != null) {
        _insertEntityStatment.execute([
          identity + entityIdentityOffset,
          _getValidName(entity.name),
          entity.type,
          x,
          y,
          entity.lost,
          entity.compromised,
          entity.importance,
        ]);
      }
    });
    storage.factors.forEach((identity, factor) {
      if (storage.entities.containsKey(factor.entity)) {
        _insertFactorStatement.execute([
          identity + factorIdentityOffset,
          factor.entity + entityIdentityOffset,
        ]);
      }
    });
    for (final dependency in storage.dependencies) {
      if (storage.factors.containsKey(dependency.factor) &&
          storage.entities.containsKey(dependency.entity)) {
        _insertDependencyStatement.execute([
          dependency.factor + factorIdentityOffset,
          dependency.entity + entityIdentityOffset,
        ]);
      }
    }
    for (final note in storage.notes) {
      if (storage.entities.containsKey(note.entity)) {
        _insertNoteStatement.execute([
          note.entity + entityIdentityOffset,
          note.text,
        ]);
      }
    }
    _commit.execute();
  }

  late final _entityExportQuery = Query(_database, '''
    select identity, name, type, x, y, lost, compromised, importance
    from entities
  ''');
  late final _factorExportQuery = Query(_database, '''
    select identity, entity
    from factors
  ''');
  late final _dependencyExportQuery = Query(_database, '''
    select entity, factor
    from dependencies
  ''');
  late final _noteExportQuery = Query(_database, '''
    select entity, text
    from notes
  ''');
  @override
  export() {
    final storage = proto.Storage();

    StorageSchema.setCompatibility(storage);

    final origin = boundaries.start;

    for (final [identity, name, type, x, y, lost, compromised, importance]
        in _entityExportQuery.selectLazy()) {
      final position = PackedIntegerPair.fromPair(
        (x as int) - origin.x,
        (y as int) - origin.y,
      );

      storage.positions[position.packed] = identity as int;
      storage.entities[identity] = proto.Entity(
        name: name as String,
        type: type as int,
        lost: lost as int,
        compromised: compromised as int,
        importance: importance as int,
      );
    }
    for (final [identity, entity] in _factorExportQuery.selectLazy()) {
      storage.factors[identity as int] = proto.Factor(entity: entity as int);
    }
    for (final [entity, factor] in _dependencyExportQuery.selectLazy()) {
      storage.dependencies.add(proto.Dependency(
        entity: entity as int,
        factor: factor as int,
      ));
    }
    for (final [entity, text] in _noteExportQuery.selectLazy()) {
      storage.notes.add(proto.Note(
        entity: entity as int,
        text: text as String,
      ));
    }

    return storage;
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
