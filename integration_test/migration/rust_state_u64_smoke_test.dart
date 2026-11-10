// Compile-only here; installed Linux/Waydroid high-u64 proof is a separate gate.
import 'dart:convert';
import 'dart:io';

// Fixture only: reuse flutter_test's already locked crypto dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_fractals/core/services/engine/rust_engine_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as native;
import 'package:integration_test/integration_test.dart';

// Produced only by run_state_session_smoke.py --extended, never copied catalogs.
const _projectedHashes = {
  'modules': 'afc6f18acd52dfdf6d11029c5d46a889f4e07393a5a9fa521a9c7e4f719a3c0f',
  'parameters':
      '46ab96397b86b330462671b2f1374257dba15bf25ec81e65630cc960c689923d',
  'presets': 'd7bb5a2651467e00414c1dbad5fb107ac666b3962e5331be9280df88e739dc87',
  'capabilities':
      'f29b25e6dd11ba3e53f1aea551488d263c3f3a98973fe0bf33be2180c796959c',
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

Map<String, Object> _params(Map<String, native.StateValue> values) {
  try {
    return {
      for (final entry in values.entries)
        entry.key: entry.value.text() ??
            entry.value.boolean() ??
            num.parse(entry.value.number()!),
    };
  } finally {
    for (final value in values.values) {
      value.dispose();
    }
  }
}

// All non-counter getters, including detached parameter handles.
List<Object?> _payload(native.StateSnapshot s) {
  final view = s.view();
  return [
    s.moduleId(),
    _params(s.params()),
    view.zoom,
    view.panX,
    view.panY,
    view.rotX,
    view.rotY,
    view.rotZ,
    s.transparentBackground(),
    s.lastAdaptiveZoom(),
    s.glowEnabled(),
    s.glowSigma(),
    s.glowIntensity(),
    s.fluidModeEnabled(),
    s.fluidStrength(),
    s.rotationLocked(),
    s.kaleidoscopeEnabled(),
    s.kaleidoscopeSectors(),
    s.kaleidoscopeMirror(),
    s.kaleidoscopeRotation(),
    s.kaleidoscopeMirrorMode(),
    s.numberWallPending(),
    s.numberWallStatus(),
  ];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fixed high-u64 outputs stay exact after source Session close',
      (tester) async {
    expect(const bool.fromEnvironment('RUST_CORE'), isTrue);
    final inputs = _inputs(); // Missing or altered --extended input must fail.
    final adapter = (await RustEngineAdapter.create())!;
    addTearDown(adapter.shutdown);
    expect(adapter.rendering, isFalse);
    final session = native.StateSession(
        modules: inputs['modules']!,
        parameters: inputs['parameters']!,
        presets: inputs['presets']!,
        capabilities: inputs['capabilities']!,
        moduleId: 'mandelbrot');
    final snapshots = <native.StateSnapshot>[];
    addTearDown(() {
      for (final snapshot in snapshots) {
        snapshot.dispose();
      }
      session.shutdown();
      session.dispose();
    });

    final initial = session.snapshot();
    snapshots.add(initial);
    final source = session.applyBatch(
        sessionId: initial.sessionId(),
        expectedRevision: initial.revision(),
        commands: [
          native.StateCommand.zoom(value: 8),
          native.StateCommand.transparent(value: true),
          native.StateCommand.glowSigma(value: 2.5),
        ]);
    snapshots.add(source);
    final expectedPayload = _payload(source);
    expect(source.numberWallFrame(), isNull);
    final fixtures = source.debugU64Fixtures();
    snapshots.addAll(fixtures);
    expect(fixtures, hasLength(2));
    expect(source.sessionId(), initial.sessionId());
    expect(source.revision(), BigInt.one);
    session.shutdown();
    expect(() => session.snapshot(), throwsA(anything));

    final expected = [
      [BigInt.parse('9007199254740993'), BigInt.parse('18446744073709551614')],
      [
        BigInt.parse('18446744073709551614'),
        BigInt.parse('18446744073709551615')
      ],
    ];
    for (var i = 0; i < fixtures.length; i++) {
      final fixture = fixtures[i];
      // Existing production u64 getters/codecs, never strings or double outputs.
      expect([fixture.sessionId(), fixture.revision()], expected[i]);
      expect(_payload(fixture), expectedPayload);
      expect(fixture.numberWallFrame(), isNull);
    }
    expect(_payload(source), expectedPayload);
    expect(source.sessionId(), initial.sessionId());
    expect(source.revision(), BigInt.one);
    expect(initial.revision(), BigInt.zero);
  });
}
