import 'storage.dart';

class TrackedDisposalStorage extends Storage {
  TrackedDisposalStorage({
    required super.name,
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  var _disposed = false;

  @override
  dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get disposed => _disposed;
}
