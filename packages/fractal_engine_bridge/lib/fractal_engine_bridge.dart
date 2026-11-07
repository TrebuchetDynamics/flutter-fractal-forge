import 'src/rust/frb_generated.dart';

export 'src/rust/api.dart';
export 'src/rust/frb_generated.dart' show RustLib;

Future<void>? _initialization;

/// Share FRB's transport, never an Engine session.
Future<void> initializeRustEngineBridge() => _initialization ??= RustLib.init();
