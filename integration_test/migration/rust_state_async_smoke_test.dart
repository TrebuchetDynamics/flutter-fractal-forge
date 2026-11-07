// Compile-only Future transport fixture; installed Linux/Waydroid runs are separate.
import 'dart:convert';
import 'dart:io';

// Fixture only: reuse flutter_test's already locked crypto dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/modules/fractals/number_wall_frame.dart';
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

  Future<native.StateSnapshot> snapshot(native.StateSession s) async =>
      retain(await s.snapshotAsync());

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

  Future<native.StateSnapshot> apply(
      native.StateSession s, List<native.StateCommand> commands) async {
    final before = await snapshot(s);
    final after = retain(s.applyBatch(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        commands: commands));
    expect(after.revision(), before.revision() + BigInt.one);
    return after;
  }

  Future<native.StateNumberWallRequest?> begin(native.StateSession s,
      native.StateCommand command, native.StateNumberWallGuard guard,
      {int budget = 100000}) async {
    final before = await snapshot(s);
    final request = await s.beginNumberWallAsync(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        command: command,
        requestGuard: guard,
        maxTrialDivisions: budget);
    if (request != null) {
      requests.add(request);
      final staged = await snapshot(s);
      expect(staged.revision(), before.revision() + BigInt.one);
      expect(staged.numberWallPending(), isTrue);
      expect(staged.numberWallStatus(), isNull);
    }
    return request;
  }

  Future<native.StateNumberWallProgress> step(native.StateSession s,
      native.StateNumberWallRequest request, int work) async {
    final before = await snapshot(s);
    final p = await s.advanceNumberWallAsync(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        request: request,
        workLimit: work);
    progresses.add(p);
    return p;
  }

  Future<native.StateNumberWallProgress> cancel(
      native.StateSession s, native.StateNumberWallRequest request) async {
    final before = await snapshot(s);
    final p = await s.cancelNumberWallAsync(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        request: request);
    progresses.add(p);
    return p;
  }

  Future<native.StateSnapshot> finish(
      native.StateSession s,
      native.StateNumberWallRequest request,
      native.StateNumberWallStatus status) async {
    final revision = (await snapshot(s)).revision();
    // Explicit awaited bounded driving, not a production scheduler or concurrency proof.
    for (var i = 0; i < 10000; i++) {
      final p = await step(s, request, 1024);
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

  Future<void> close() async {
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
      await s.shutdownAsync();
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
      'awaited bounded steps match exact Dart frames and retain certified state on rejection',
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
      final before = (await f.snapshot(s));
      final request = (await f.begin(
          s, _loadWall('00097', source: source.name), f.guard()))!;
      final staged = (await f.snapshot(s));
      expect(staged.moduleId(), before.moduleId());
      expect(_params(staged.params()), _params(before.params()));
      final zero = (await f.step(s, request, 0));
      expect(zero.isPending(), isTrue);
      expect(f.retain(zero.snapshot()).revision(), staged.revision());
      final one = (await f.step(s, request, 1));
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
      final good = (await f.finish(
          s, request, native.StateNumberWallStatus.verifiedPrime));
      expect(good.moduleId(), 'number_wall');
      expect(good.view(), _camera.view);
      expect(good.transparentBackground(), isTrue);
      _compareFrame(f, good, prepared.frame!);
      expect(staged.numberWallPending(), isTrue); // Detached retained snapshot.
    }
    final good = (await f.snapshot(s));
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
      final request = (await f.begin(s,
          native.StateCommand.numberWallPrime(value: candidate.$1), f.guard(),
          budget: candidate.$3))!;
      final rejected = (await f.finish(s, request, candidate.$2));
      expect(_params(rejected.params()), params);
      expect(f.frame(rejected).values(), values);
      expect(rejected.view(), good.view());
      expect(rejected.transparentBackground(), good.transparentBackground());
    }
  });

  testWidgets(
      'awaited borrowed requests enforce ownership, navigation and closed lifecycle',
      (tester) async {
    final f = await _fixture();
    final s = f.create();
    final other = f.create();
    final inactive = f.guard(active: false);
    expect(inactive.isActive(), isFalse);
    expect((await f.begin(s, _loadWall('97'), inactive)), isNull);
    expect((await f.snapshot(s)).revision(), BigInt.zero);
    final guard = f.guard();
    final old = (await f.begin(s, _loadWall('97'), guard))!;
    expect((await f.step(s, old, 1)).isPending(), isTrue);
    final admitted = (await f.snapshot(s));
    guard.revoke();
    guard.revoke();
    expect(guard.isActive(), isFalse);
    final revoked = (await f.step(s, old, 0));
    expect(revoked.status(), native.StateNumberWallStatus.cancelled);
    final cancelled = f.retain(revoked.snapshot());
    expect(cancelled.revision(), admitted.revision() + BigInt.one);
    expect(cancelled.numberWallPending(), isFalse);
    expect(
        cancelled.numberWallStatus(), native.StateNumberWallStatus.cancelled);
    final supersededGuard = f.guard();
    final superseded = (await f.begin(s, _loadWall('103'), supersededGuard))!;
    final successor = (await f.begin(s, _loadWall('101'), f.guard()))!;
    supersededGuard.revoke();
    final pending = (await f.snapshot(s));
    expect((await f.begin(s, _loadWall('107'), supersededGuard)), isNull);
    expect((await f.cancel(s, superseded)).status(),
        native.StateNumberWallStatus.cancelled);
    expect((await f.step(s, superseded, 0)).status(),
        native.StateNumberWallStatus.cancelled);
    expect((await f.snapshot(s)).revision(), pending.revision());
    expect((await f.snapshot(s)).numberWallPending(), isTrue);
    final foreign = (await f.begin(other, _loadWall('109'), f.guard()))!;
    final otherBefore = (await f.snapshot(other));
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
      await expectLater(
          s.beginNumberWallAsync(
              sessionId: invalid.$1,
              expectedRevision: invalid.$2,
              command: _loadWall('107'),
              requestGuard: guard,
              maxTrialDivisions: 1),
          throwsA(contains(invalid.$3)));
      await expectLater(
          s.advanceNumberWallAsync(
              sessionId: invalid.$1,
              expectedRevision: invalid.$2,
              request: successor,
              workLimit: 1),
          throwsA(contains(invalid.$3)));
      await expectLater(
          s.cancelNumberWallAsync(
              sessionId: invalid.$1,
              expectedRevision: invalid.$2,
              request: successor),
          throwsA(contains(invalid.$3)));
    }
    await expectLater(
        s.advanceNumberWallAsync(
            sessionId: pending.sessionId(),
            expectedRevision: pending.revision(),
            request: foreign,
            workLimit: 1),
        throwsA(contains('WrongSession')));
    await expectLater(
        s.cancelNumberWallAsync(
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
    expect((await f.snapshot(s)).revision(), pending.revision());
    expect((await f.snapshot(s)).glowEnabled(), isFalse);
    final good = (await f.finish(
        s, successor, native.StateNumberWallStatus.verifiedPrime));
    final frame = f.frame(good);
    final values = frame.values();
    final params = _params(frame.params());
    expect(frame.modulus(), '101');
    final explicit = (await f.begin(s, _loadWall('107'), f.guard()))!;
    final explicitBefore = (await f.snapshot(s));
    final stop = (await f.cancel(s, explicit));
    expect(stop.status(), native.StateNumberWallStatus.cancelled);
    final stopped = f.retain(stop.snapshot());
    expect(stopped.revision(), explicitBefore.revision() + BigInt.one);
    expect(stopped.numberWallPending(), isFalse);
    expect((await f.cancel(s, explicit)).status(),
        native.StateNumberWallStatus.cancelled);
    expect((await f.snapshot(s)).revision(), stopped.revision());
    final abandoned = (await f.begin(s, _loadWall('107'), f.guard()))!;
    final navigated = (await f.apply(s, [_select('julia')]));
    expect(navigated.moduleId(), 'julia');
    expect(navigated.numberWallPending(), isFalse);
    expect((await f.step(s, abandoned, 0)).status(),
        native.StateNumberWallStatus.cancelled);
    expect((await f.snapshot(s)).revision(), navigated.revision());
    expect(frame.values(), values);
    expect(f.frame(navigated).values(), values);
    final immediateBefore = (await f.snapshot(s));
    expect((await f.begin(s, native.StateCommand.zoom(value: 3), f.guard())),
        isNull);
    expect((await f.snapshot(s)).revision(),
        immediateBefore.revision() + BigInt.one);
    expect((await f.snapshot(s)).view().zoom, 3);
    final unfinished = (await f.begin(s, _loadWall('113'), f.guard()))!;
    final beforeClose = (await f.snapshot(s));
    await s.shutdownAsync();
    await s.shutdownAsync();
    await expectLater(
        s.snapshotAsync(), throwsA(contains('session is closed')));
    expect(
        () => s.applyBatch(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            commands: []),
        throwsA(contains('session is closed')));
    await expectLater(
        s.beginNumberWallAsync(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            command: _loadWall('127'),
            requestGuard: guard,
            maxTrialDivisions: 1),
        throwsA(contains('session is closed')));
    await expectLater(
        s.advanceNumberWallAsync(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            request: unfinished,
            workLimit: 0),
        throwsA(contains('session is closed')));
    await expectLater(
        s.cancelNumberWallAsync(
            sessionId: beforeClose.sessionId(),
            expectedRevision: beforeClose.revision(),
            request: unfinished),
        throwsA(contains('session is closed')));
    expect(frame.values(), values);
    expect(_params(frame.params()), params);
    expect(frame.modulus(), '101');
    expect(beforeClose.numberWallPending(), isTrue);
    expect((await f.snapshot(other)).revision(), otherBefore.revision());
    expect((await f.snapshot(other)).numberWallPending(), isTrue);
    (await f.finish(
        other, foreign, native.StateNumberWallStatus.verifiedPrime));
  });
}
