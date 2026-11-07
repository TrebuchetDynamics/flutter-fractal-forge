import 'package:flutter/foundation.dart';

import 'rust_engine_loader_stub.dart'
    if (dart.library.io) 'rust_engine_loader_native.dart' as platform;

/// Only the probe crosses this seam. Rendering/state stay with the legacy owner.
abstract interface class RustEngineBridge {
  String engineVersion();
  RustEngineSession createEngine();
}

abstract interface class RustEngineSession {
  bool get rendering;
  void shutdown();
}

class RustEngineAdapter {
  RustEngineAdapter._(this.version, this._session);

  final String version;
  final RustEngineSession _session;
  bool _closed = false;

  static Future<RustEngineAdapter?> create({
    bool enabled = const bool.fromEnvironment('RUST_CORE'),
    bool isWeb = kIsWeb,
    Future<RustEngineBridge> Function()? loader,
  }) async {
    if (!enabled || kIsWeb || isWeb) return null;
    final bridge = await (loader ?? platform.loadRustEngine)();
    final version = bridge.engineVersion();
    return RustEngineAdapter._(version, bridge.createEngine());
  }

  bool get rendering {
    if (_closed) throw StateError('Rust engine session is closed');
    return _session.rendering;
  }

  void shutdown() {
    if (_closed) return;
    _session.shutdown();
    _closed = true;
  }
}
