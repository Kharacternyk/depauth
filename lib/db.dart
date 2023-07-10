import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'types.dart';

class Db {
  final Map<Position, WeakReference<ValueNotifier<Entity?>>> _entities = {};
  final ValueNotifier<Boundaries> boundaries;
  final Database db;

  ValueNotifier<Entity?> getEntity(Position position) {
    switch (_entities[position]) {
      case null:
        final entity = ValueNotifier<Entity?>(_getEntity(position));
        _entities[position] = WeakReference(entity);
        return entity;
      case WeakReference<ValueNotifier<Entity?>> reference:
        switch (reference.target) {
          case null:
            final entity = ValueNotifier<Entity?>(_getEntity(position));
            _entities[position] = WeakReference(entity);
            return entity;
          case ValueNotifier<Entity?> entity:
            return entity;
        }
    }
  }

  Entity? _getEntity(Position position) {
    final statement = db.prepare('''
      select name, type
      from entities
      where x = ? and y = ?
    ''');

    final row = statement.select([position.x, position.y]).firstOrNull;
    return switch (row) {
      null => null,
      Row row => Entity(
          row['name'] as String,
          EntityType.values[row['type'] as int],
        ),
    };
  }

  void moveEntity({required Position from, required Position to}) {
    final statement = db.prepare('''
        update entities
        set x = ?, y = ?
        where x = ? and y = ?;
      ''');

    statement.execute(
      [to.x, to.y, from.x, from.y],
    );

    _entities[to]?.target?.value = _entities[from]?.target?.value;
    _entities[from]?.target?.value = null;
  }

  Db._(this.db, this.boundaries);

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

    final statement = db.prepare('''
      select min(x), min(y), max(x), max(y)
      from entities;
    ''');

    final values = statement.select().first.values;

    return Db._(
      db,
      ValueNotifier(
        Boundaries(
          Position(values[0] as int, values[1] as int),
          Position(values[2] as int, values[3] as int),
        ),
      ),
    );
  }
}
