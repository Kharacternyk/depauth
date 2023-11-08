import 'storage.pb.dart';

sealed class Compatibility {}

class CompatibilityMatch implements Compatibility {
  final Storage storage;

  const CompatibilityMatch(this.storage);
}

class VersionMismatch implements Compatibility {
  const VersionMismatch();
}

class ApplicationMismatch implements Compatibility {
  const ApplicationMismatch();
}
