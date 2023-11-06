import 'dart:io';

extension AwaitFileRelease on File {
  Future<void> get release async {
    final openedFile = await open(mode: FileMode.writeOnlyAppend);

    await openedFile.lock(FileLock.blockingExclusive);
    await openedFile.unlock();
    await openedFile.close();
  }
}
