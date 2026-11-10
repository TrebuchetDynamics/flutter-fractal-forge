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
  RustEngineSession createEngine() => _NativeSession(native.createEngine());
}

class _NativeSession implements RustEngineSession {
  _NativeSession(this._engine);
  final native.EngineHandle _engine;

  @override
  bool get rendering => false;

  @override
  native.EngineSnapshot snapshot() => native.engineSnapshot(engine: _engine);

  @override
  void shutdown() {
    _engine.dispose();
  }
}
