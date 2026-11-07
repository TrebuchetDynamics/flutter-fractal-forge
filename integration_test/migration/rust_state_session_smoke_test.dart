import 'dart:convert';
import 'dart:io';

// Fixture only: reuse flutter_test's already locked crypto dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/engine/rust_engine_adapter.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/policy/backend_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as native;
import 'package:integration_test/integration_test.dart';

const _projectedHashes = {
  'modules': 'da7bad4bfde2db8e5a995a9ca1a314c6bc965664de6c12bb42413776b5e1165e',
  'parameters':
      '2ac3fea39d030b3acf18c2e361f5859426ef709914ff9b75582cd0664b05e762',
  'presets': 'b24a99f57fcff5e0052d1ef44fbced8731bcb4b6e39a5cfd58a03c10db052beb',
  'capabilities':
      '1041f69847161b0ede0bf5413cfa4613d9f0aaa16e9a5a5fcb51c14e6effe8fa',
};

String _decode(String kind, String encoded) {
  if (encoded.isEmpty) throw FormatException('Missing STATE_SESSION_$kind');
  final bytes = zlib.decode(base64.decode(encoded));
  if (sha256.convert(bytes).toString() != _projectedHashes[kind]) {
    throw FormatException('Tampered STATE_SESSION_$kind');
  }
  return utf8.decode(bytes);
}

Map<String, String> _inputs() => {
      'modules': _decode(
          'modules', const String.fromEnvironment('STATE_SESSION_MODULES')),
      'parameters': _decode('parameters',
          const String.fromEnvironment('STATE_SESSION_PARAMETERS')),
      'presets': _decode(
          'presets', const String.fromEnvironment('STATE_SESSION_PRESETS')),
      'capabilities': _decode('capabilities',
          const String.fromEnvironment('STATE_SESSION_CAPABILITIES')),
    };

// Readback handles are retained/explicitly disposed; owned command/value arguments
// are freshly constructed for every call and consumed by generated transport.
Map<String, Object?> _state(native.StateSnapshot snapshot) {
  final params = snapshot.params();
  try {
    return {
      'module': snapshot.moduleId(),
      'view': snapshot.view(),
      'transparent': snapshot.transparentBackground(),
      'adaptiveZoom': snapshot.lastAdaptiveZoom(),
      'params': {
        for (final entry in params.entries)
          entry.key: [
            entry.value.number(),
            entry.value.text(),
            entry.value.boolean(),
            entry.value.float()
          ],
      },
    };
  } finally {
    for (final value in params.values) {
      value.dispose();
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'source-bound input protocol refuses missing/truncated/tampered data',
      (tester) async {
    final inputs = _inputs(); // Missing flags fail; never skip native evidence.
    expect(inputs.keys, _projectedHashes.keys);
    expect(() => _decode('modules', ''), throwsFormatException);
    final encoded = base64.encode(zlib.encode(utf8.encode(inputs['modules']!)));
    expect(() => _decode('modules', encoded.substring(0, encoded.length ~/ 2)),
        throwsA(anything));
    expect(
        () => _decode('modules', base64.encode(zlib.encode(utf8.encode('{}')))),
        throwsFormatException);
  });

  testWidgets(
      'real synchronous StateSessions preserve transactions and lifecycle',
      (tester) async {
    expect(const bool.fromEnvironment('RUST_CORE'), isTrue);
    expect(
        await RustEngineAdapter.create(
            enabled: false,
            loader: () async {
              fail('default-off must not load native code');
            }),
        isNull);
    final inputs = _inputs();
    final adapter = (await RustEngineAdapter.create())!;
    final sessions = <native.StateSession>[];
    final snapshots = <native.StateSnapshot>[];
    native.StateSnapshot retain(native.StateSnapshot snapshot) {
      snapshots.add(snapshot);
      return snapshot;
    }

    native.StateSession create(String module) {
      final session = native.StateSession(
        modules: inputs['modules']!,
        parameters: inputs['parameters']!,
        presets: inputs['presets']!,
        capabilities: inputs['capabilities']!,
        moduleId: module,
      );
      sessions.add(session);
      return session;
    }

    native.StateSnapshot apply(
        native.StateSession session, List<native.StateCommand> commands) {
      final before = retain(session.snapshot());
      return retain(session.applyBatch(
          sessionId: before.sessionId(),
          expectedRevision: before.revision(),
          commands: commands));
    }

    try {
      expect(adapter.version, '0.1.0');
      expect(adapter.rendering, isFalse);
      expect(
          const RendererBackendPolicy()
              .decide(const BackendPolicyInput(
                isAndroid: false,
                isWeb: false,
                isEmulator: false,
                userMode: RendererBackendMode.auto,
                gpuHealthFailed: false,
                deepZoomNeedsCpu: false,
                dimension: FractalDimension.twoD,
              ))
              .backend,
          RendererBackend.gpu);
      final first = create('mandelbrot');
      final singleton = create('mandelbrot');
      final initial = retain(first.snapshot());
      final independent = retain(singleton.snapshot());
      final initialState = _state(initial);
      expect(initial.sessionId(), isNot(independent.sessionId()));
      expect(initial.revision(), BigInt.zero);
      expect(_state(independent), initialState);

      // Source defaults for each of the four projected modules remain the oracle.
      final presets =
          (jsonDecode(inputs['presets']!) as Map)['payload']['records'] as List;
      final ids = <BigInt>{initial.sessionId(), independent.sessionId()};
      for (final record in presets) {
        final session = create(record['module_id'] as String);
        final snapshot = retain(session.snapshot());
        expect(ids.add(snapshot.sessionId()), isTrue);
        expect(snapshot.moduleId(), record['module_id']);
        final values = snapshot.params();
        try {
          for (final entry in (record['default']['params'] as Map).entries) {
            final value = values[entry.key]!;
            if (entry.value is bool) {
              expect(value.boolean(), entry.value);
              expect(value.number(), isNull);
            } else {
              expect(num.parse(value.number()!), entry.value);
              expect(value.text(), isNull);
            }
          }
        } finally {
          for (final value in values.values) {
            value.dispose();
          }
        }
      }

      List<native.StateCommand Function()> ordered() => [
            () => native.StateCommand.zoom(value: 64),
            () => native.StateCommand.pan(x: 1, y: -1),
            () => native.StateCommand.rotation(x: 0, y: 0, z: 0.5),
            () => native.StateCommand.zoom(value: 32),
            () => native.StateCommand.transparent(value: true),
          ];
      final batched =
          apply(first, [for (final command in ordered()) command()]);
      native.StateSnapshot sequential = independent;
      for (final command in ordered()) {
        sequential = apply(singleton, [command()]);
      }
      expect(_state(batched), _state(sequential));
      expect(batched.revision(), BigInt.one);
      expect(sequential.revision(), BigInt.from(5));
      expect(batched.view().zoom, 32);
      expect(batched.view().panX, 1);
      expect(batched.view().rotZ, 0.5);
      expect(batched.transparentBackground(), isTrue);
      expect(_state(initial), initialState);

      // Nonfinite view fields retain/clamp; a nonfinite parameter uses schema default.
      final normalized = apply(first, [
        native.StateCommand.pan(x: double.nan, y: double.infinity),
        native.StateCommand.rotation(
            x: double.nan, y: double.infinity, z: double.negativeInfinity),
        native.StateCommand.param(
            id: 'iterations',
            value: native.StateValue.fromFloat(value: double.nan)),
      ]);
      expect(normalized.view().panX, 1);
      expect(normalized.view().panY, 3);
      expect(normalized.view().rotX, 0);
      expect(normalized.view().rotY, 0);
      expect(normalized.view().rotZ, 0.5);
      final schemas = (jsonDecode(inputs['parameters']!) as Map)['payload']
          ['records'] as List;
      final schema = schemas.singleWhere((r) => r['module_id'] == 'mandelbrot');
      final iteration = (schema['parameters'] as List)
          .singleWhere((p) => p['id'] == 'iterations');
      final values = normalized.params();
      try {
        expect(
            num.parse(values['iterations']!.number()!), iteration['default']);
      } finally {
        for (final value in values.values) {
          value.dispose();
        }
      }

      final before = _state(normalized);
      final id = normalized.sessionId();
      final revision = normalized.revision();
      expect(
          retain(first.applyBatch(
              sessionId: id,
              expectedRevision: revision,
              commands: [])).revision(),
          revision);
      // These are stale input operands, NOT successful high-u64 snapshot outputs.
      for (final wrong in [
        independent.sessionId(),
        BigInt.parse('9007199254740993'),
        BigInt.parse('18446744073709551615')
      ]) {
        expect(
            () => first.applyBatch(
                sessionId: wrong, expectedRevision: revision, commands: []),
            throwsA(contains('WrongSession')));
      }
      for (final stale in [
        BigInt.zero,
        BigInt.parse('9007199254740993'),
        BigInt.parse('18446744073709551615')
      ]) {
        expect(
            () => first.applyBatch(
                sessionId: id, expectedRevision: stale, commands: []),
            throwsA(contains('StaleRevision')));
      }
      for (final failure in <String, native.StateCommand Function()>{
        'UnsupportedOperation("randomize")': () =>
            native.StateCommand.unsupported(operation: 'randomize'),
        'UnsupportedModule("number_walls")': () =>
            native.StateCommand.selectModule(
                moduleId: 'number_walls', resetView: false, initialParams: {}),
        'UnsupportedTrajectory': () => native.StateCommand.view(
            camera: native.StateCamera(
                view: normalized.view(), hasTrajectory: true),
            adaptive: false),
      }.entries) {
        expect(
            () => first.applyBatch(
                    sessionId: id,
                    expectedRevision: revision,
                    commands: [
                      native.StateCommand.transparent(value: false),
                      failure.value()
                    ]),
            throwsA(contains(failure.key)));
        final unchanged = retain(first.snapshot());
        expect(unchanged.revision(), revision);
        expect(_state(unchanged), before);
      }
      final noop = apply(first, [native.StateCommand.transparent(value: true)]);
      expect(noop.revision(), revision + BigInt.one);
      expect(_state(noop), before);
      expect(
          () => first.applyBatch(
              sessionId: id, expectedRevision: revision, commands: []),
          throwsA(contains('StaleRevision')));

      final reset = apply(first, [native.StateCommand.resetSession()]);
      expect(reset.transparentBackground(), isFalse);
      expect(_state(initial), initialState); // retained after resets, too
      first.shutdown();
      first.shutdown();
      expect(() => first.snapshot(), throwsA(contains('session is closed')));
      expect(
          () => first.applyBatch(
              sessionId: id, expectedRevision: reset.revision(), commands: []),
          throwsA(contains('session is closed')));
      expect(_state(initial), initialState); // detached even after shutdown
      expect(initial.revision(), BigInt.zero);
      expect(initial.sessionId(), id);
      expect(_state(retain(singleton.snapshot())), _state(sequential));
      expect(adapter.rendering, isFalse);
    } finally {
      for (final snapshot in snapshots) {
        snapshot.dispose();
      }
      for (final session in sessions) {
        session.shutdown();
        session.dispose();
      }
      adapter.shutdown();
      adapter.shutdown();
    }
    expect(() => adapter.rendering, throwsStateError);
  });

  testWidgets('native StateValue getters retain exact scalar type and text',
      (tester) async {
    final adapter = (await RustEngineAdapter.create())!;
    const exact = '9007199254740993';
    final number = native.StateValue.fromNumber(value: exact);
    final text = native.StateValue.fromText(value: exact);
    final boolean = native.StateValue.fromBoolean(value: true);
    final floating = native.StateValue.fromFloat(value: double.infinity);
    final nan = native.StateValue.fromFloat(value: double.nan);
    try {
      expect([number.number(), number.text(), number.boolean(), number.float()],
          [exact, null, null, null]);
      expect([text.number(), text.text(), text.boolean(), text.float()],
          [null, exact, null, null]);
      expect([
        boolean.number(),
        boolean.text(),
        boolean.boolean(),
        boolean.float()
      ], [
        null,
        null,
        true,
        null
      ]);
      expect(floating.float(), double.infinity);
      expect(nan.float()!.isNaN, isTrue);
      expect(() => native.StateValue.fromNumber(value: 'not a number'),
          throwsA(contains('Invalid number')));
    } finally {
      for (final value in [number, text, boolean, floating, nan]) {
        value.dispose();
      }
      adapter.shutdown();
    }
  });
}
