import 'process_memory_reader_stub.dart'
    if (dart.library.io) 'process_memory_reader_io.dart';

/// Returns the current process resident-set size, or null when unsupported.
int? readProcessRssBytes() => readCurrentProcessRssBytes();
