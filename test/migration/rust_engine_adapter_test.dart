import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/policy/backend_policy.dart';
import 'package:flutter_fractals/core/services/engine/rust_engine_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default-off and Web never load Rust or change renderer selection',
      () async {
    Future<RustEngineBridge> forbiddenLoader() async =>
        throw StateError('native load must not happen');
    expect(await RustEngineAdapter.create(loader: forbiddenLoader), isNull);
    expect(
      await RustEngineAdapter.create(
        enabled: true,
        isWeb: true,
        loader: forbiddenLoader,
      ),
      isNull,
    );
    expect(const RendererBackendPolicy().decide(_legacyInput).backend,
        RendererBackend.gpu);
  });

  test('sessions expose version/capabilities, close once and remain isolated',
      () async {
    final bridge = _Bridge();
    final first = (await RustEngineAdapter.create(
      enabled: true,
      loader: () async => bridge,
    ))!;
    final second = (await RustEngineAdapter.create(
      enabled: true,
      loader: () async => bridge,
    ))!;
    expect(first.version, '0.1.0');
    expect(first.rendering, isFalse);
    first.shutdown();
    first.shutdown();
    expect(bridge.sessions.first.shutdowns, 1);
    expect(() => first.rendering, throwsStateError);
    expect(second.rendering, isFalse);
    second.shutdown();
  });

  test('bridge failures stay visible, without changing renderer selection',
      () async {
    final failure = StateError('native library unavailable');
    await expectLater(
      RustEngineAdapter.create(
          enabled: true, loader: () async => throw failure),
      throwsA(same(failure)),
    );
    final bridge = _Bridge();
    final adapter = (await RustEngineAdapter.create(
      enabled: true,
      loader: () async => bridge,
    ))!;
    bridge.sessions.single.failure = failure;
    expect(() => adapter.rendering, throwsA(same(failure)));
    adapter.shutdown();
    expect(const RendererBackendPolicy().decide(_legacyInput).backend,
        RendererBackend.gpu);
  });
}

const _legacyInput = BackendPolicyInput(
  isAndroid: false,
  isWeb: false,
  isEmulator: false,
  userMode: RendererBackendMode.auto,
  gpuHealthFailed: false,
  deepZoomNeedsCpu: false,
  dimension: FractalDimension.twoD,
);

class _Bridge implements RustEngineBridge {
  final sessions = <_Session>[];
  @override
  String engineVersion() => '0.1.0';
  @override
  RustEngineSession createEngine() {
    final session = _Session();
    sessions.add(session);
    return session;
  }
}

class _Session implements RustEngineSession {
  int shutdowns = 0;
  Object? failure;
  @override
  bool get rendering {
    if (failure != null) throw failure!;
    return false;
  }

  @override
  void shutdown() => shutdowns++;
}
