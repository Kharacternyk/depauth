import 'package:sqlite3/sqlite3.dart';

import 'query.dart';
import 'statement.dart';
import 'storage_directory_map_key.dart';

class StorageDirectoryMap {
  final Database _database;

  StorageDirectoryMap(String path) : _database = sqlite3.open(path)..execute('''
    pragma auto_vacuum = full;
    pragma encoding = 'UTF-8';
    pragma locking_mode = exclusive;
    pragma synchronous = full;
    pragma user_version = 1;

    create table if not exists map(
      key integer primary key,
      value any not null
    ) strict, without rowid;
  ''');

  void dispose() {
    _database.dispose();
  }

  String? get activeStoragePendingName {
    return _get(StorageDirectoryMapKey.activeStoragePendingName) as String?;
  }

  set activeStoragePendingName(String? value) {
    _setOrClear(StorageDirectoryMapKey.activeStoragePendingName, value);
  }

  void _setOrClear(StorageDirectoryMapKey key, Object? value) {
    if (value != null) {
      _set(key, value);
    } else {
      _clear(key);
    }
  }

  late final _valueQuery = Query(_database, '''
    select value from map where key = ?
  ''');
  Object? _get(StorageDirectoryMapKey key) {
    return _valueQuery.selectOne([key.index])?.first;
  }

  late final _setValueStatement = Statement(_database, '''
    insert into map(key, value) values(?, ?)
    on conflict(key) do update set value = ?
  ''');
  void _set(StorageDirectoryMapKey key, Object value) {
    _setValueStatement.execute([key.index, value, value]);
  }

  late final _clearValueStatement = Statement(_database, '''
    delete from map where key = ?
  ''');
  void _clear(StorageDirectoryMapKey key) {
    _clearValueStatement.execute([key.index]);
  }
}
