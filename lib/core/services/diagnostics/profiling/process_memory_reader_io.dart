import 'dart:io';

int? readCurrentProcessRssBytes() {
  try {
    final bytes = ProcessInfo.currentRss;
    return bytes > 0 ? bytes : null;
  } on UnsupportedError {
    return null;
  } on FileSystemException {
    return null;
  }
}
