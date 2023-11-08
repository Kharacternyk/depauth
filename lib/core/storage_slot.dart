import 'storage.pb.dart' as proto;

abstract interface class StorageSlot {
  void import(proto.Storage storage);
  proto.Storage export();
}
