import 'package:sqlite3/sqlite3.dart';

import 'types.dart';

class Db {
  final (Position, Position) Function() getMapBoundaries;
  final void Function(EntityId id, Position position) setEntityPosition;
  final Entity? Function(EntityId id) getEntity;
  final EntityId? Function(Position position) getEntityId;
  final List<EntityId> Function(EntityId id) getDependencies;

  Db._({
    required this.getMapBoundaries,
    required this.setEntityPosition,
    required this.getEntity,
    required this.getEntityId,
    required this.getDependencies,
  });

  factory Db() {
    final db = sqlite3.openInMemory();

    db.execute('''
      pragma foreign_keys = on;

      create table if not exists entities (
        id integer primary key,
        name text not null unique,
        type integer not null,
        x integer not null,
        y integer not null,
        unique(x, y)
      ) strict;

      create table if not exists dependencies (
        source integer not null references entities on delete cascade,
        destination integer not null references entities on delete cascade,
        primary key(source, destination)
      ) strict, without rowid;
    ''');

    db.prepare('''
      insert into entities(id, name, type, x, y) values (?, ?, ?, ?, ?);
    ''')
      ..execute([0, 'Google', 0, 1, 1])
      ..execute([1, 'Fastmail', 0, 1, 2])
      ..execute([2, 'Yubikey', 1, 1, 3])
      ..execute([3, 'Nazar', 2, 2, 1])
      ..dispose();

    db.prepare('''
      insert into dependencies(source, destination) values (?, ?);
    ''')
      ..execute([0, 1])
      ..execute([1, 0])
      ..execute([0, 3])
      ..execute([1, 3])
      ..dispose();

    final Map<EntityId, Entity?> entityCache = {};
    final Map<Position, EntityId?> idCache = {};
    final Map<EntityId, List<EntityId>> dependencyCache = {};

    return Db._(
      getMapBoundaries: () {
        final statement = db.prepare('''
          select min(x), min(y), max(x), max(y)
          from entities;
        ''');

        return () {
          final values = statement.select().first.values;
          return (
            Position(values[0] as int, values[1] as int),
            Position(values[2] as int, values[3] as int),
          );
        };
      }(),
      setEntityPosition: () {
        final statement = db.prepare('''
          update entities
          set x = ?, y = ?
          where id = ?;
        ''');

        return (EntityId id, Position position) {
          statement.execute(
            [position.x, position.y, id.value],
          );
          idCache.clear();
        };
      }(),
      getEntity: () {
        final statement = db.prepare('''
          select name, type
          from entities
          where id = ?
        ''');

        return (EntityId id) {
          if (!entityCache.containsKey(id)) {
            final row = statement.select([id.value]).firstOrNull;
            entityCache[id] = switch (row) {
              null => null,
              Row row => Entity(
                  row['name'] as String,
                  EntityType.values[row['type'] as int],
                ),
            };
          }

          return entityCache[id];
        };
      }(),
      getEntityId: () {
        final statement = db.prepare('''
          select id
          from entities
          where x = ? and y = ?
        ''');

        return (Position position) {
          if (!idCache.containsKey(position)) {
            final row = statement.select([position.x, position.y]).firstOrNull;
            idCache[position] = switch (row) {
              null => null,
              Row row => EntityId(row['id'] as int),
            };
          }

          return idCache[position];
        };
      }(),
      getDependencies: () {
        final statement = db.prepare('''
          select destination
          from dependencies
          where source = ?
        ''');

        return (EntityId id) {
          if (!dependencyCache.containsKey(id)) {
            final rows = statement.select([id.value]);
            dependencyCache[id] =
                rows.map((row) => EntityId(row['destination'] as int)).toList();
          }

          return dependencyCache[id] ?? [];
        };
      }(),
    );
  }
}
