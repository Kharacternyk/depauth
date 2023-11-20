import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'active_record.dart';
import 'boundaries.dart';
import 'dependency.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'factor_digest.dart';
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
    select factors.identity, threshold
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
    _beginRead();

    final values = _entityQuery.selectOne([position.x, position.y]);

    TraversableEntity? entity;

    if (values != null) {
      final [identity, name, type, note] = values;
      final passport = EntityPassport._(
        Identity._(identity as int),
        position,
      );

      entity = TraversableEntity(
        passport,
        name as String,
        EntityType(type as int),
        _factorsQuery.select([identity], (values) {
          final [factorIdentity, threshold] = values;
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
            threshold as int,
          );
        }),
        note as String?,
      );
    }

    _commitRead();

    return entity;
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

  late final _createEntityQuery = Query(_database, '''
    insert into entities(name, type, x, y, lost, compromised, importance)
    values(?, 0, ?, ?, false, false, 0)
    returning identity
  ''');
  Identity<Entity> createEntity(Position position, String name) {
    return Identity._(
      _createEntityQuery.selectOne([
        _getValidName(name),
        position.x,
        position.y,
      ])?.first as int,
    );
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

  late final _addNoteStatement = Statement(_database, '''
    insert into notes(entity, text)
    values(?, ?)
  ''');
  @override
  addNote(entity, note) {
    _addNoteStatement.execute([entity.identity._value, note]);
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

  late final _removeNoteStatement = Statement(_database, '''
    delete from notes
    where entity = ?
  ''');
  @override
  removeNote(entity) {
    _removeNoteStatement.execute([entity.identity._value]);
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
    _beginWrite();
    _addFactorStatement.execute([entity.identity._value]);
    _moveDependencyAsFactorStatement.execute([
      dependency.factor.identity._value,
      dependency.identity._value,
    ]);
    _commitWrite();
  }

  late final _addFactorStatement = Statement(_database, '''
    insert into factors(entity, threshold) values(?, 1)
  ''');
  @override
  addFactor(entity) {
    _addFactorStatement.execute([entity.identity._value]);
  }

  late final _changeThresholdStatement = Statement(_database, '''
    update factors
    set threshold = ?
    where identity = ?
  ''');
  @override
  changeThreshold(factor, value) {
    _changeThresholdStatement.execute([value, factor.identity._value]);
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
    _beginWrite();
    _mergeFactorsStatement.execute([
      into.identity._value,
      from.identity._value,
    ]);
    _removeFactorStatement.execute([from.identity._value]);
    _commitWrite();
  }

  late final _addDependencyAsFactorStatement = Statement(_database, '''
    insert into dependencies(entity, factor) values(?, last_insert_rowid())
  ''');
  @override
  addDependencyAsFactor(entity, dependency) {
    _beginWrite();
    _addFactorStatement.execute([entity.identity._value]);
    _addDependencyAsFactorStatement.execute([dependency._value]);
    _commitWrite();
  }

  late final _factorIdentitiesQuery = Query(_database, '''
    select identity, threshold
    from factors
    where entity = ?
  ''');
  Iterable<FactorDigest> getFactors(Identity<Entity> entity) {
    return _factorIdentitiesQuery.select([entity._value], (values) {
      final [identity, threshold] = values;

      return FactorDigest(Identity._(identity as int), threshold as int);
    });
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

  late final _originEntitiesQuery = Query(_database, '''
    select entities.identity
    from entities
    left join factors
    on entity = entities.identity
    where factors.identity is null
  ''');
  Iterable<Identity<Entity>> get originEntities {
    return _originEntitiesQuery.select(null, _parseIdentity);
  }

  late final _lostEntitiesQuery = Query(_database, '''
    select identity
    from entities
    where lost
  ''');
  Iterable<Identity<Entity>> get lostEntities {
    return _lostEntitiesQuery.select(null, _parseIdentity);
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

  Stream<double> copy(String path) async* {
    final copy = sqlite3.open(path);

    yield* _database.backup(copy);

    copy.dispose();
  }

  void touch() => _database.touchSchema();

  late final _insertEntityStatement = Statement(_database, '''
    insert into entities(name, type, x, y, lost, compromised, importance)
    values(?, ?, ?, ?, ?, ?, ?)
  ''');
  late final _insertFactorQuery = Query(_database, '''
    insert into factors(entity, threshold)
    select identity, ?
    from entities
    where x = ? and y = ?
    returning identity
  ''');
  late final _insertDependencyStatement = Statement(_database, '''
    insert into dependencies(factor, entity)
    select ?, identity
    from entities
    where x = ? and y = ?
  ''');
  late final _insertNoteStatement = Statement(_database, '''
    insert into notes(entity, text)
    values(last_insert_rowid(), ?)
  ''');
  @override
  import(storage) {
    _beginWrite();

    final boundaries = this.boundaries;
    final origin = (
      x: boundaries.end.x,
      y: boundaries.start.y,
    );

    (int, int) unpack(int integer) {
      final pair = PackedIntegerPair.fromPacked(integer);

      return (pair.first + origin.x, pair.second + origin.y);
    }

    storage.entities.forEach((position, entity) {
      final (x, y) = unpack(position);

      _insertEntityStatement.execute([
        _getValidName(entity.name),
        entity.type,
        x,
        y,
        entity.lost,
        entity.compromised,
        entity.importance,
      ]);

      if (entity.hasNote()) {
        _insertNoteStatement.execute([entity.note.text]);
      }
    });

    for (final factor in storage.factors) {
      if (storage.entities.containsKey(factor.entity)) {
        final (x, y) = unpack(factor.entity);
        final identity = _insertFactorQuery
            .selectOne([factor.threshold, x, y])?.first as int;

        for (final dependency in factor.dependencies.keys) {
          if (storage.entities.containsKey(dependency)) {
            final (x, y) = unpack(dependency);

            _insertDependencyStatement.execute([identity, x, y]);
          }
        }
      }
    }

    _commitWrite();
  }

  late final _entityExportQuery = Query(_database, '''
    select entities.identity, name, type, x, y, lost, compromised, importance, text
    from entities
    left join notes
    on entity = entities.identity
  ''');
  late final _factorExportQuery = Query(_database, '''
    select identity, threshold
    from factors
    where entity = ?
  ''');
  late final _dependencyExportQuery = Query(_database, '''
    select x, y
    from dependencies
    join entities
    on dependencies.entity = entities.identity
    where factor = ?
  ''');
  @override
  export() {
    final storage = proto.Storage();

    StorageSchema.setCompatibility(storage);
    _beginRead();

    final origin = boundaries.start;

    int pack(int x, int y) {
      return PackedIntegerPair.fromPair(x - origin.x, y - origin.y).packed;
    }

    for (final [identity, name, type, x, y, lost, compromised, importance, note]
        in _entityExportQuery.selectLazy()) {
      final position = pack(x as int, y as int);

      storage.entities[position] = proto.Entity(
        name: name as String,
        type: type as int,
        lost: lost as int,
        compromised: compromised as int,
        importance: importance as int,
        note: (note as String?) == null ? null : proto.Note(text: note),
      );

      for (final [factorIdentity, threshold]
          in _factorExportQuery.selectLazy([identity])) {
        final factor =
            proto.Factor(entity: position, threshold: threshold as int);

        for (final [x, y]
            in _dependencyExportQuery.selectLazy([factorIdentity])) {
          factor.dependencies[pack(x as int, y as int)] = proto.Dependency();
        }

        storage.factors.add(factor);
      }
    }

    _commitRead();

    return storage;
  }

  late final _beginReadStatement = switch (Platform.isAndroid) {
    false => null,
    true => Statement(_database, '''
      begin
    '''),
  };
  void _beginRead() => _beginReadStatement?.execute();

  late final _beginWriteStatement = Statement(_database, '''
    begin immediate
  ''');
  void _beginWrite() => _beginWriteStatement.execute();

  late final _commitReadStatement =
      Platform.isAndroid ? _commitWriteStatement : null;
  void _commitRead() => _commitReadStatement?.execute();

  late final _commitWriteStatement = Statement(_database, '''
    commit
  ''');
  void _commitWrite() => _commitWriteStatement.execute();

  Position _parsePosition(Values values) {
    final [x, y] = values;

    return Position(x as int, y as int);
  }

  Identity<T> _parseIdentity<T>(Values values) {
    return Identity._(values.first as int);
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
