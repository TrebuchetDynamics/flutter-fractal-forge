import 'dart:convert';
import 'dart:io';

// Fixture only: reuse flutter_test's already locked crypto dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/modules/fractals/number_wall_frame.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
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

List<Object> _effects(native.StateSnapshot s) => [
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
    ];

List<Object> _dartEffects(FractalController c) => [
      c.glowEnabled,
      c.glowSigma,
      c.glowIntensity,
      c.fluidModeEnabled,
      c.fluidStrength,
      c.rotationLocked,
      c.kaleidoscopeEnabled,
      c.kaleidoscopeSectors,
      c.kaleidoscopeMirror,
      c.kaleidoscopeRotation,
      c.kaleidoscopeMirrorMode,
    ];

native.StateCommand _select(String module) => native.StateCommand.selectModule(
    moduleId: module, resetView: false, initialParams: {});

const _camera = native.StateCamera(
    view: native.StateView(
        zoom: 2, panX: 0.5, panY: -0.5, rotX: 0.1, rotY: 0.2, rotZ: 0.3),
    hasTrajectory: false);

native.StateCommand _loadWall(String prime, {String source = 'rook'}) =>
    native.StateCommand.load(
      moduleId: 'number_wall',
      params: {
        'prime': native.StateValue.fromText(value: prime),
        'source': native.StateValue.fromText(value: source),
        'rows': native.StateValue.fromNumber(value: '4'),
        'columns': native.StateValue.fromNumber(value: '16'),
        'columnStart': native.StateValue.fromNumber(value: '3'),
      },
      camera: _camera,
      transparent: true,
    );

// Own every returned handle explicitly. Commands/values are fresh and consumed;
// guard/request arguments are borrowed and remain usable until fixture cleanup.
class _Fixture {
  _Fixture(this.inputs);
  final Map<String, String> inputs;
  final sessions = <native.StateSession>[];
  final snapshots = <native.StateSnapshot>[];
  final guards = <native.StateNumberWallGuard>[];
  final requests = <native.StateNumberWallRequest>[];
  final progresses = <native.StateNumberWallProgress>[];
  final frames = <native.StateNumberWallFrame>[];

  native.StateSession create([String module = 'mandelbrot']) {
    final s = native.StateSession(
        modules: inputs['modules']!,
        parameters: inputs['parameters']!,
        presets: inputs['presets']!,
        capabilities: inputs['capabilities']!,
        moduleId: module);
    sessions.add(s);
    return s;
  }

  native.StateSnapshot retain(native.StateSnapshot s) {
    snapshots.add(s);
    return s;
  }

  native.StateSnapshot snapshot(native.StateSession s) => retain(s.snapshot());

  native.StateNumberWallFrame frame(native.StateSnapshot s) {
    final frame = s.numberWallFrame()!;
    frames.add(frame);
    return frame;
  }

  native.StateNumberWallGuard guard({bool active = true}) {
    final g = native.StateNumberWallGuard(active: active);
    guards.add(g);
    return g;
  }

  native.StateSnapshot apply(
      native.StateSession s, List<native.StateCommand> commands) {
    final before = snapshot(s);
    final after = retain(s.applyBatch(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        commands: commands));
    expect(after.revision(), before.revision() + BigInt.one);
    return after;
  }

  native.StateNumberWallRequest? begin(native.StateSession s,
      native.StateCommand command, native.StateNumberWallGuard guard,
      {int budget = 100000}) {
    final before = snapshot(s);
    final request = s.beginNumberWall(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        command: command,
        requestGuard: guard,
        maxTrialDivisions: budget);
    if (request != null) {
      requests.add(request);
      final staged = snapshot(s);
      expect(staged.revision(), before.revision() + BigInt.one);
      expect(staged.numberWallPending(), isTrue);
      expect(staged.numberWallStatus(), isNull);
    }
    return request;
  }

  native.StateNumberWallProgress step(
      native.StateSession s, native.StateNumberWallRequest request, int work) {
    final before = snapshot(s);
    final p = s.advanceNumberWall(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        request: request,
        workLimit: work);
    progresses.add(p);
    return p;
  }

  native.StateNumberWallProgress cancel(
      native.StateSession s, native.StateNumberWallRequest request) {
    final before = snapshot(s);
    final p = s.cancelNumberWall(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        request: request);
    progresses.add(p);
    return p;
  }

  native.StateSnapshot finish(
      native.StateSession s,
      native.StateNumberWallRequest request,
      native.StateNumberWallStatus status) {
    final revision = snapshot(s).revision();
    // Explicit bounded fixture driving, not a production executor or concurrency proof.
    for (var i = 0; i < 10000; i++) {
      final p = step(s, request, 1024);
      final after = retain(p.snapshot());
      expect(after.numberWallPending(), p.isPending());
      expect(after.revision(),
          revision + (p.isPending() ? BigInt.zero : BigInt.one));
      if (p.isPending()) {
        expect(p.status(), isNull);
      } else {
        expect(p.status(), status);
        expect(after.numberWallStatus(), status);
        return after;
      }
    }
    throw StateError('bounded Number Walls fixture did not terminate');
  }

  void close() {
    for (final frame in frames) {
      frame.dispose();
    }
    for (final p in progresses) {
      p.dispose();
    }
    for (final s in snapshots) {
      s.dispose();
    }
    for (final r in requests) {
      r.dispose();
    }
    for (final g in guards) {
      g.dispose();
    }
    for (final s in sessions) {
      s.shutdown();
      s.dispose();
    }
  }
}

void _compareFrame(
    _Fixture f, native.StateSnapshot snapshot, NumberWallFrame oracle) {
  final frame = f.frame(snapshot);
  final grid = oracle.grid;
  expect(_params(snapshot.params()), oracle.params);
  expect(_params(frame.params()), oracle.params);
  expect(frame.sequence().name, grid.sequence.name);
  expect(frame.modulus(), grid.prime.toString());
  expect(frame.rowCount(), grid.rowCount);
  expect(frame.columnCount(), grid.columnCount);
  expect(frame.columnStart(), grid.columnStart);
  expect([frame.supportStart(), frame.supportEnd()],
      [grid.support.start, grid.support.end]);
  final expected = [
    for (final row in grid.values) [for (final cell in row) cell.toString()]
  ];
  expect(frame.values(), expected); // Every cell, without float narrowing.
  final detached = frame.values();
  detached[0][0] = 'mutated';
  expect(frame.values(), expected);
}

Future<_Fixture> _fixture() async {
  expect(const bool.fromEnvironment('RUST_CORE'), isTrue);
  final adapter = (await RustEngineAdapter.create())!;
  addTearDown(adapter.shutdown);
  expect(adapter.rendering, isFalse);
  final f = _Fixture(_inputs());
  addTearDown(f.close);
  return f;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'extended source protocol refuses missing/truncated/tampered inputs',
      (tester) async {
    final inputs =
        _inputs(); // Missing input is a failure, not a native-test skip.
    expect(inputs.keys, _projectedHashes.keys);
    for (final kind in inputs.keys) {
      expect(() => _decode(kind, ''), throwsFormatException);
      final encoded = base64.encode(zlib.encode(utf8.encode(inputs[kind]!)));
      expect(() => _decode(kind, encoded.substring(0, encoded.length ~/ 2)),
          throwsA(anything));
      expect(() => _decode(kind, base64.encode(zlib.encode(utf8.encode('{}')))),
          throwsFormatException);
    }
    expect(
        await RustEngineAdapter.create(
            enabled: false,
            loader: () async {
              fail('default-off must not load native code');
            }),
        isNull);
  });

  testWidgets(
      'eleven native effects restore forced policy and roll back atomically',
      (tester) async {
    final f = await _fixture();
    final s = f.create();
    final other = f.create();
    final registry = ModuleRegistry();
    final oracle = FractalController(registry);
    addTearDown(oracle.dispose);
    native.StateSnapshot edit(
        native.StateCommand command, void Function() dartEdit) {
      final after = f.apply(s, [command]);
      dartEdit();
      expect(_effects(after), _dartEffects(oracle));
      return after;
    }

    final initialEffects = _dartEffects(oracle);
    expect(_effects(f.snapshot(s)), initialEffects);
    edit(native.StateCommand.glowEnabled(value: true),
        () => oracle.setGlowEnabled(true));
    edit(native.StateCommand.glowSigma(value: 2.5),
        () => oracle.setGlowSigma(2.5));
    edit(native.StateCommand.glowIntensity(value: 0.6),
        () => oracle.setGlowIntensity(0.6));
    edit(native.StateCommand.fluidModeEnabled(value: true),
        () => oracle.setFluidModeEnabled(true));
    edit(native.StateCommand.fluidStrength(value: 1.6),
        () => oracle.setFluidStrength(1.6));
    edit(native.StateCommand.rotationLocked(value: true),
        () => oracle.setRotationLocked(true));
    edit(native.StateCommand.kaleidoscopeEnabled(value: false),
        () => oracle.setKaleidoscopeEnabled(false));
    edit(native.StateCommand.kaleidoscopeSectors(value: 6),
        () => oracle.setKaleidoscopeSectors(6));
    edit(native.StateCommand.kaleidoscopeMirror(value: false),
        () => oracle.setKaleidoscopeMirror(false));
    edit(native.StateCommand.kaleidoscopeRotation(value: 0.25),
        () => oracle.setKaleidoscopeRotation(0.25));
    final user = edit(native.StateCommand.kaleidoscopeMirrorMode(value: 1),
        () => oracle.setKaleidoscopeMirrorMode(1));
    final retained = _effects(user);
    edit(
        _select('kaleidoscope_basic'),
        () => oracle.selectModule(registry.byId('kaleidoscope_basic'),
            animate: false));
    edit(native.StateCommand.kaleidoscopeEnabled(value: false),
        () => oracle.setKaleidoscopeEnabled(false));
    edit(native.StateCommand.kaleidoscopeSectors(value: 10),
        () => oracle.setKaleidoscopeSectors(10));
    edit(native.StateCommand.kaleidoscopeMirrorMode(value: 2),
        () => oracle.setKaleidoscopeMirrorMode(2));
    final forced = edit(
        _select('kaleidoscope_fractal'),
        () => oracle.selectModule(registry.byId('kaleidoscope_fractal'),
            animate: false));
    final before = _effects(forced);
    expect(
        () => s.applyBatch(
                sessionId: forced.sessionId(),
                expectedRevision: forced.revision(),
                commands: [
                  native.StateCommand.glowEnabled(value: false),
                  _select('julia'),
                  native.StateCommand.kaleidoscopeSectors(value: 14),
                  _select('kaleidoscope_basic'),
                  native.StateCommand.unsupported(operation: 'effect rollback'),
                ]),
        throwsA(contains('UnsupportedOperation')));
    final unchanged = f.snapshot(s);
    expect(unchanged.revision(), forced.revision());
    expect(unchanged.moduleId(), forced.moduleId());
    expect(_effects(unchanged), before);
    expect(_params(unchanged.params()), _params(forced.params()));
    expect(unchanged.view(), forced.view());
    expect(unchanged.transparentBackground(), forced.transparentBackground());
    final restored = edit(_select('julia'),
        () => oracle.selectModule(registry.byId('julia'), animate: false));
    expect(_effects(restored), retained);
    expect(_effects(user), retained);
    expect(_effects(forced), before);
    expect(f.snapshot(other).revision(), BigInt.zero);
    expect(_effects(f.snapshot(other)), initialEffects);
    s.shutdown();
    s.shutdown();
    expect(() => s.snapshot(), throwsA(contains('session is closed')));
    expect(
        () => s.applyBatch(
            sessionId: restored.sessionId(),
            expectedRevision: restored.revision(),
            commands: [native.StateCommand.glowEnabled(value: false)]),
        throwsA(contains('session is closed')));
    expect(_effects(restored), retained);
  });

  testWidgets(
      'staged native frames match the Dart oracle and retain certified state on rejection',
      (tester) async {
    final f = await _fixture();
    final s = f.create();
    final schemas = (jsonDecode(f.inputs['parameters']!) as Map)['payload']
        ['records'] as List;
    final wall = schemas.singleWhere((r) => r['module_id'] == 'number_wall');
    final defaults = <String, Object>{
      for (final p in wall['parameters'] as List)
        p['id'] as String: p['default'] as Object
    };
    for (final source in NumberWallSequence.values) {
      final before = f.snapshot(s);
      final request =
          f.begin(s, _loadWall('00097', source: source.name), f.guard())!;
      final staged = f.snapshot(s);
      expect(staged.moduleId(), before.moduleId());
      expect(_params(staged.params()), _params(before.params()));
      final zero = f.step(s, request, 0);
      expect(zero.isPending(), isTrue);
      expect(f.retain(zero.snapshot()).revision(), staged.revision());
      final one = f.step(s, request, 1);
      expect(one.isPending(), isTrue);
      expect(f.retain(one.snapshot()).revision(), staged.revision());
      final prepared = await NumberWallFrame.prepare({
        ...defaults,
        'prime': '00097',
        'source': source.name,
        'rows': 4,
        'columns': 16,
        'columnStart': 3
      }, isCancelled: () => false);
      expect(prepared.status, NumberWallPrimeStatus.verifiedPrime);
      final good =
          f.finish(s, request, native.StateNumberWallStatus.verifiedPrime);
      expect(good.moduleId(), 'number_wall');
      expect(good.view(), _camera.view);
      expect(good.transparentBackground(), isTrue);
      _compareFrame(f, good, prepared.frame!);
      expect(staged.numberWallPending(), isTrue); // Detached retained snapshot.
    }
    final good = f.snapshot(s);
    final values = f.frame(good).values();
    final params = _params(good.params());
    for (final candidate in [
      ('1e2', native.StateNumberWallStatus.invalid, 100000),
      ('561', native.StateNumberWallStatus.composite, 100000),
      (
        '170141183460469231731687303715884105727',
        native.StateNumberWallStatus.unverified,
        0
      ),
    ]) {
      final request = f.begin(s,
          native.StateCommand.numberWallPrime(value: candidate.$1), f.guard(),
          budget: candidate.$3)!;
      final rejected = f.finish(s, request, candidate.$2);
      expect(_params(rejected.params()), params);
      expect(f.frame(rejected).values(), values);
      expect(rejected.view(), good.view());
      expect(rejected.transparentBackground(), good.transparentBackground());
    }
  });

  testWidgets(
      'borrowed native requests enforce ownership, navigation and closed lifecycle',
      (tester) async {
    final f = await _fixture();
    final s = f.create();
    final other = f.create();
    final inactive = f.guard(active: false);
    expect(inactive.isActive(), isFalse);
    expect(f.begin(s, _loadWall('97'), inactive), isNull);
    expect(f.snapshot(s).revision(), BigInt.zero);
    final guard = f.guard();
    final old = f.begin(s, _loadWall('97'), guard)!;
    expect(f.step(s, old, 1).isPending(), isTrue);
    final admitted = f.snapshot(s);
    guard.revoke();
    guard.revoke();
    expect(guard.isActive(), isFalse);
    final revoked = f.step(s, old, 0);
    expect(revoked.status(), native.StateNumberWallStatus.cancelled);
    final cancelled = f.retain(revoked.snapshot());
    expect(cancelled.revision(), admitted.revision() + BigInt.one);
    expect(cancelled.numberWallPending(), isFalse);
    expect(
        cancelled.numberWallStatus(), native.StateNumberWallStatus.cancelled);
    final supersededGuard = f.guard();
    final superseded = f.begin(s, _loadWall('103'), supersededGuard)!;
    final successor = f.begin(s, _loadWall('101'), f.guard())!;
    supersededGuard.revoke();
    final pending = f.snapshot(s);
    expect(f.begin(s, _loadWall('107'), supersededGuard), isNull);
    expect(f.cancel(s, superseded).status(),
        native.StateNumberWallStatus.cancelled);
    expect(f.step(s, superseded, 0).status(),
        native.StateNumberWallStatus.cancelled);
    expect(f.snapshot(s).revision(), pending.revision());
    expect(f.snapshot(s).numberWallPending(), isTrue);
    final foreign = f.begin(other, _loadWall('109'), f.guard())!;
    final otherBefore = f.snapshot(other);
    // Wrong/stale operands are input-only checks, not successful high-u64 outputs.
    for (final invalid in [
      (otherBefore.sessionId(), pending.revision(), 'WrongSession'),
      (pending.sessionId(), pending.revision() - BigInt.one, 'StaleRevision'),
      (
        BigInt.parse('18446744073709551615'),
        pending.revision(),
        'WrongSession'
      ),
      (pending.sessionId(), BigInt.parse('9007199254740993'), 'StaleRevision'),
    ]) {
      expect(
          () => s.beginNumberWall(
              sessionId: invalid.$1,
              expectedRevision: invalid.$2,
              command: _loadWall('107'),
              requestGuard: guard,
              maxTrialDivisions: 1),
          throwsA(contains(invalid.$3)));
      expect(
          () => s.advanceNumberWall(
              sessionId: invalid.$1,
              expectedRevision: invalid.$2,
              request: successor,
              workLimit: 1),
          throwsA(contains(invalid.$3)));
      expect(
          () => s.cancelNumberWall(
              sessionId: invalid.$1,
              expectedRevision: invalid.$2,
              request: successor),
          throwsA(contains(invalid.$3)));
    }
    expect(
        () => s.advanceNumberWall(
            sessionId: pending.sessionId(),
            expectedRevision: pending.revision(),
            request: foreign,
            workLimit: 1),
        throwsA(contains('WrongSession')));
    expect(
        () => s.cancelNumberWall(
            sessionId: pending.sessionId(),
            expectedRevision: pending.revision(),
            request: foreign),
        throwsA(contains('WrongSession')));
    expect(
        () => s.applyBatch(
                sessionId: pending.sessionId(),
                expectedRevision: pending.revision(),
                commands: [
                  native.StateCommand.glowEnabled(value: true),
                  _loadWall('107'),
                ]),
        throwsA(contains('DeferredOperation')));
    expect(f.snapshot(s).revision(), pending.revision());
    expect(f.snapshot(s).glowEnabled(), isFalse);
    final good =
        f.finish(s, successor, native.StateNumberWallStatus.verifiedPrime);
    final frame = f.frame(good);
    final values = frame.values();
    final params = _params(frame.params());
    expect(frame.modulus(), '101');
    final explicit = f.begin(s, _loadWall('107'), f.guard())!;
    final explicitBefore = f.snapshot(s);
    final stop = f.cancel(s, explicit);
    expect(stop.status(), native.StateNumberWallStatus.cancelled);
    final stopped = f.retain(stop.snapshot());
    expect(stopped.revision(), explicitBefore.revision() + BigInt.one);
    expect(stopped.numberWallPending(), isFalse);
    expect(
        f.cancel(s, explicit).status(), native.StateNumberWallStatus.cancelled);
    expect(f.snapshot(s).revision(), stopped.revision());
    final abandoned = f.begin(s, _loadWall('107'), f.guard())!;
    final navigated = f.apply(s, [_select('julia')]);
    expect(navigated.moduleId(), 'julia');
    expect(navigated.numberWallPending(), isFalse);
    expect(f.step(s, abandoned, 0).status(),
        native.StateNumberWallStatus.cancelled);
    expect(f.snapshot(s).revision(), navigated.revision());
    expect(frame.values(), values);
    expect(f.frame(navigated).values(), values);
    final immediateBefore = f.snapshot(s);
    expect(f.begin(s, native.StateCommand.zoom(value: 3), f.guard()), isNull);
    expect(f.snapshot(s).revision(), immediateBefore.revision() + BigInt.one);
    expect(f.snapshot(s).view().zoom, 3);
    final unfinished = f.begin(s, _loadWall('113'), f.guard())!;
    final beforeClose = f.snapshot(s);
    s.shutdown();
    s.shutdown();
    expect(() => s.snapshot(), throwsA(contains('session is closed')));
    expect(
        () => s.applyBatch(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            commands: []),
        throwsA(contains('session is closed')));
    expect(
        () => s.beginNumberWall(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            command: _loadWall('127'),
            requestGuard: guard,
            maxTrialDivisions: 1),
        throwsA(contains('session is closed')));
    expect(
        () => s.advanceNumberWall(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            request: unfinished,
            workLimit: 0),
        throwsA(contains('session is closed')));
    expect(
        () => s.cancelNumberWall(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            request: unfinished),
        throwsA(contains('session is closed')));
    expect(frame.values(), values);
    expect(_params(frame.params()), params);
    expect(frame.modulus(), '101');
    expect(beforeClose.numberWallPending(), isTrue);
    expect(f.snapshot(other).revision(), otherBefore.revision());
    expect(f.snapshot(other).numberWallPending(), isTrue);
    f.finish(other, foreign, native.StateNumberWallStatus.verifiedPrime);
  });
}
