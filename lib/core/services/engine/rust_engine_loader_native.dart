import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as native;

import 'rust_engine_adapter.dart';

Future<RustEngineBridge> loadRustEngine() async {
  await native.initializeRustEngineBridge();
  return _NativeBridge();
}

class _NativeBridge implements RustEngineBridge {
  @override
  String engineVersion() => native.engineVersion();

  @override
  RustEngineSession createEngine() => _NativeSession(native.Engine());
}

class _NativeSession implements RustEngineSession {
  _NativeSession(this._engine);
  final native.Engine _engine;

  @override
  bool get rendering => _engine.capabilities().rendering;

  @override
  void shutdown() {
    _engine.shutdown();
    _engine.dispose();
  }
}
