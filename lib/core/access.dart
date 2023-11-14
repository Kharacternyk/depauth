sealed class Access<T> {
  bool get present;
}

class OriginAccess<T> implements Access<T> {
  const OriginAccess();

  @override
  bool get present => true;
}

class BlockedAccess<T> implements Access<T> {
  const BlockedAccess();

  @override
  bool get present => false;
}

class DerivedAccess<T> implements Access<T> {
  final Iterable<T> derivedFrom;

  const DerivedAccess(this.derivedFrom);

  @override
  bool get present => derivedFrom.isNotEmpty;
}
