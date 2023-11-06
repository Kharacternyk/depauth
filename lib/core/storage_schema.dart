import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:sqlite3/sqlite3.dart';

import 'compatibility.dart';

extension StorageSchema on Database {
  static const _identity = 1147498561;
  static const _version = 1;

  void applyStorageSchema() {
    execute('''
      pragma application_id = $_identity;
      pragma foreign_keys = true;
      pragma auto_vacuum = full;
      pragma cache_size = -100000;
      pragma encoding = 'UTF-8';
      pragma locking_mode = exclusive;
      pragma synchronous = full;
      pragma user_version = $_version;

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
      create index if not exists entity_loss on entities(lost);
      create index if not exists entity_compromise on entities(compromised);
      create index if not exists entity_importance on entities(importance);

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
  }

  static Future<Compatibility> getCompatibility(XFile file) async {
    final builder = BytesBuilder();

    await file.openRead(0, 100).forEach(builder.add);

    final bytes = builder.takeBytes();

    if (bytes.isEmpty) {
      return Compatibility.match;
    }
    if (bytes.length < 100) {
      return Compatibility.applicationMismatch;
    }

    const magic = [
      83,
      81,
      76,
      105,
      116,
      101,
      32,
      102,
      111,
      114,
      109,
      97,
      116,
      32,
      51,
      0,
    ];

    for (var i = 0; i < magic.length; ++i) {
      if (bytes[i] != magic[i]) {
        return Compatibility.applicationMismatch;
      }
    }

    var identity = 0;

    for (var i = 0; i < 4; ++i) {
      identity <<= 8;
      identity += bytes[68 + i];
    }

    if (identity != _identity) {
      return Compatibility.applicationMismatch;
    }

    var version = 0;

    for (var i = 0; i < 4; ++i) {
      version <<= 8;
      version += bytes[60 + i];
    }

    if (version > _version) {
      return Compatibility.versionMismatch;
    }

    return Compatibility.match;
  }
}
