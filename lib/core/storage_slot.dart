import 'storage.pb.dart';

abstract interface class StorageSlot {
  void import(Storage storage);
  Storage export();
}
