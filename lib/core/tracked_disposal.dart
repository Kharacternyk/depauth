class TrackedDisposal {
  var _disposed = false;
  void dispose() => _disposed = true;
  bool get disposed => _disposed;
}
