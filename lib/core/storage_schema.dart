import 'package:cross_file/cross_file.dart';
import 'package:sqlite3/sqlite3.dart';

import 'compatibility.dart';
import 'storage.pb.dart';

extension StorageSchema on Database {
  static const _identity = 1147498561;
  static const _version = (
    internal: 1,
    external: 1,
  );

  void applyStorageSchema() {
    execute('''
      pragma cache_size = -100000;
      pragma encoding = 'UTF-8';
      pragma foreign_keys = true;
      pragma locking_mode = exclusive;
      pragma synchronous = full;

      begin immediate;

      pragma application_id = $_identity;
      pragma auto_vacuum = full;
      pragma user_version = ${_version.internal};

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

      commit;
    ''');
  }

  static Future<Compatibility> getCompatibility(XFile file) async {
    final List<int> bytes;

    try {
      bytes = await file.readAsBytes();
    } on Exception {
      return const ApplicationMismatch();
    }

    final Storage storage;

    try {
      storage = Storage.fromBuffer(bytes);
    } on Exception {
      return const ApplicationMismatch();
    }
    if (storage.identity != _identity) {
      return const ApplicationMismatch();
    }
    if (storage.version > _version.external) {
      return const VersionMismatch();
    }

    return CompatibilityMatch(storage);
  }

  static void setCompatibility(Storage storage) {
    storage.identity = _identity;
    storage.version = _version.external;
  }
}
