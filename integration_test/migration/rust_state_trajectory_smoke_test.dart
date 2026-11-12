// Installed qualification results are recorded per target in docs/tasks/.
import 'dart:convert';
import 'dart:io';

// Fixture only: reuse flutter_test's already locked crypto dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_fractals/core/modules/attractor_trajectory.dart';
import 'package:flutter_fractals/core/services/engine/rust_engine_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as native;
import 'package:integration_test/integration_test.dart';

// Produced only by run_state_session_smoke.py --trajectory.
const _projectedHashes = {
  'modules': '83198465bebb3c9a7b15f9149be088fa2dd4a12291f7fdf11d9a84b92ee0032d',
  'parameters':
      'e632d446426f15fd91b7b2ba857223933bf4fab78f882f42a76af1e4af94c9bd',
  'presets': '32a03b55f5b4407ab36a94209ab48a80812740316ca039d8dc558926356d108c',
  'capabilities':
      'be4156405585d0f56ca806c1f08346ef2447ed9dbc2d29a97d2d180a2ae82b1f',
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

const _view = native.StateView(
    zoom: 2, panX: 0.5, panY: -0.5, rotX: 0.1, rotY: 0.2, rotZ: 0.3);

// FRB spells Lorenz2d as lorenz2D; Dart's model uses lorenz2d.
// Explicit exhaustive mappings make codegen naming changes compile-time failures.
native.StateAttractorSystem _system(AttractorSystem system) => switch (system) {
      AttractorSystem.thomas => native.StateAttractorSystem.thomas,
      AttractorSystem.fourWing => native.StateAttractorSystem.fourWing,
      AttractorSystem.lorenz2d => native.StateAttractorSystem.lorenz2D,
    };

native.StateOrbitProjection _projection(OrbitProjection projection) =>
    switch (projection) {
      OrbitProjection.xz => native.StateOrbitProjection.xz,
      OrbitProjection.thomasOblique =>
        native.StateOrbitProjection.thomasOblique,
    };

native.StateTrajectorySettings _settings(OrbitTrajectorySettings s) =>
    native.StateTrajectorySettings(
        version: s.version,
        integrator: s.integrator,
        system: _system(s.system),
        seed: native.StateOrbitPoint(x: s.seed.x, y: s.seed.y, z: s.seed.z),
        stepSize: s.stepSize,
        burnInSteps: s.burnInSteps,
        retainedSteps: s.retainedSteps,
        projection: _projection(s.projection));

// Fresh commands/cameras/settings are consumed. All returned and borrowed handles
// are retained explicitly until teardown, including requests after supersession.
class _Fixture {
  final inputs = _inputs();
  final sessions = <native.StateSession>[];
  final snapshots = <native.StateSnapshot>[];
  final guards = <native.StateTrajectoryGuard>[];
  final requests = <native.StateTrajectoryRequest>[];
  final progresses = <native.StateTrajectoryProgress>[];
  final frames = <native.StateTrajectoryFrame>[];

  native.StateSession create(String module) {
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

  native.StateTrajectoryGuard guard({bool active = true}) {
    final g = native.StateTrajectoryGuard(active: active);
    guards.add(g);
    return g;
  }

  Future<native.StateSnapshot> apply(
      native.StateSession s, native.StateCommand command) async {
    final before = await snapshot(s);
    return retain(s.applyBatch(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        commands: [command]));
  }

  Future<native.StateSnapshot> configure(
          native.StateSession s, OrbitTrajectorySettings settings) =>
      apply(
          s,
          native.StateCommand.viewTrajectory(
              camera: native.StateTrajectoryCamera(
                  view: _view, trajectory: _settings(settings)),
              adaptive: false));

  Future<native.StateTrajectoryRequest?> begin(
      native.StateSession s, native.StateTrajectoryGuard guard) async {
    final before = await snapshot(s);
    final r = await s.beginTrajectoryAsync(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        requestGuard: guard);
    if (r != null) requests.add(r);
    return r;
  }

  Future<native.StateTrajectoryProgress> step(
      native.StateSession s, native.StateTrajectoryRequest r) async {
    final before = await snapshot(s);
    final p = await s.advanceTrajectoryAsync(
        sessionId: before.sessionId(),
        expectedRevision: before.revision(),
        request: r);
    progresses.add(p);
    final after = retain(p.snapshot());
    expect(after.revision(),
        before.revision() + (p.isPending() ? BigInt.zero : BigInt.one));
    return p;
  }

  native.StateTrajectoryFrame frame(native.StateTrajectoryProgress p) {
    final frame = p.frame()!;
    frames.add(frame);
    return frame;
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

void _compareSettings(
    native.StateTrajectorySettings actual, OrbitTrajectorySettings expected) {
  try {
    expect(actual.version(), expected.version);
    expect(actual.integrator(), expected.integrator);
    expect(actual.system(), _system(expected.system));
    expect(actual.projection(), _projection(expected.projection));
    expect(actual.stepSize(), expected.stepSize);
    expect(actual.burnInSteps(), expected.burnInSteps);
    expect(actual.retainedSteps(), expected.retainedSteps);
    final seed = actual.seed();
    expect([seed.x, seed.y, seed.z],
        [expected.seed.x, expected.seed.y, expected.seed.z]);
  } finally {
    actual.dispose();
  }
}

void _compareFrame(
    native.StateTrajectoryFrame frame, OrbitTrajectorySettings settings) {
  _compareSettings(frame.settings(), settings);
  final expected = AttractorTrajectoryModel.generate(settings);
  final points = frame.points();
  expect(points.length, expected.points.length);
  for (var i = 0; i < points.length; i++) {
    final a = points[i], b = expected.points[i];
    expect(a.x, closeTo(b.x, 1e-10));
    expect(a.y, closeTo(b.y, 1e-10));
    expect(a.z, closeTo(b.z, 1e-10));
  }
  final b = frame.bounds(), e = expected.bounds;
  expect(b.minX, closeTo(e.minX, 1e-10));
  expect(b.maxX, closeTo(e.maxX, 1e-10));
  expect(b.minY, closeTo(e.minY, 1e-10));
  expect(b.maxY, closeTo(e.maxY, 1e-10));
  final first = points.first;
  points[0] = const native.StateOrbitPoint(x: 0, y: 0, z: 0);
  expect(frame.points().first, first); // Whole getter returns a detached list.
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('typed bounded trajectory requests and retained native frames',
      (tester) async {
    expect(const bool.fromEnvironment('RUST_CORE'), isTrue);
    final adapter = (await RustEngineAdapter.create())!;
    addTearDown(adapter.shutdown);
    expect(adapter.rendering, isFalse);
    // Waydroid can deny run-as; bind the loaded library from inside the process.
    if (Platform.isAndroid) {
      final mappings = File('/proc/self/maps').readAsLinesSync().where(
          (line) => line.trim().endsWith('/libfractal_bridge.so'));
      expect(mappings, isNotEmpty);
      final path = mappings.first.trim().split(RegExp(r'\s+')).last;
      final digest = sha256.convert(File(path).readAsBytesSync());
      // ignore: avoid_print
      print('Loaded Rust SO: $path sha256=$digest rendering=${adapter.rendering}');
    }
    final f = _Fixture();
    addTearDown(f.close);
    for (final module in ['thomas_attractor', 'four_wing', 'lorenz_2d']) {
      final s = f.create(module);
      final defaults = OrbitTrajectorySettings.defaultsFor(module);
      _compareSettings((await f.snapshot(s)).trajectory()!, defaults);
      final settings = defaults.copyWith(
          burnInSteps: 10, retainedSteps: 600, stepSize: 0.009);
      final configured = await f.configure(s, settings);
      _compareSettings(configured.trajectory()!, settings);
      final guard = f.guard();
      expect(await f.begin(s, f.guard(active: false)), isNull);
      final request = (await f.begin(s, guard))!;
      final pending = await f.step(s, request);
      expect(pending.isPending(), isTrue);
      expect(pending.stepsCompleted(), 256);
      final captured = f.retain(pending.snapshot());
      expect(captured.trajectoryPending(), isTrue);
      expect(captured.trajectoryStatus(), isNull);
      await expectLater(
          s.advanceTrajectoryAsync(
              sessionId: captured.sessionId(),
              expectedRevision: configured.revision(),
              request: request),
          throwsA(anything));
      expect((await f.step(s, request)).stepsCompleted(), 512);
      final done = await f.step(s, request);
      expect(done.status(), native.StateTrajectoryStatus.success);
      final frame = f.frame(done);
      expect(frame.cacheHit(), isFalse);
      expect(frame.sessionId(), captured.sessionId());
      expect(frame.settingsGeneration(), configured.trajectoryGeneration());
      expect(frame.moduleId(), module);
      _compareFrame(frame, settings);
      final terminal = f.retain(done.snapshot());
      expect(terminal.trajectoryStatus(), native.StateTrajectoryStatus.success);
      final retained = terminal.trajectoryFrame()!;
      f.frames.add(retained);

      final other = f.create(module);
      await f.configure(other, settings);
      final foreign = await f.snapshot(other);
      await expectLater(
          other.advanceTrajectoryAsync(
              sessionId: foreign.sessionId(),
              expectedRevision: foreign.revision(),
              request: request),
          throwsA(anything));
      final cached = await f.step(other, (await f.begin(other, guard))!);
      expect(f.frame(cached).cacheHit(), isTrue);
      _compareFrame(f.frames.last, settings);

      final old = (await f.begin(s, guard))!;
      final current = (await f.begin(s, guard))!;
      // Stale request returns cancellation without clearing the current owner.
      final beforeOld = await f.snapshot(s);
      final obsolete = await s.advanceTrajectoryAsync(
          sessionId: beforeOld.sessionId(),
          expectedRevision: beforeOld.revision(),
          request: old);
      f.progresses.add(obsolete);
      expect(obsolete.status(), native.StateTrajectoryStatus.cancelled);
      expect((await f.snapshot(s)).trajectoryPending(), isTrue);
      guard.revoke();
      expect(guard.isActive(), isFalse);
      expect((await f.step(s, current)).status(),
          native.StateTrajectoryStatus.cancelled);
      final active = f.guard();
      final cancel = (await f.begin(s, active))!;
      final beforeCancel = await f.snapshot(s);
      final cancelled = await s.cancelTrajectoryAsync(
          sessionId: beforeCancel.sessionId(),
          expectedRevision: beforeCancel.revision(),
          request: cancel);
      f.progresses.add(cancelled);
      expect(cancelled.status(), native.StateTrajectoryStatus.cancelled);

      expect(
          () => s.applyBatch(
                  sessionId: beforeCancel.sessionId(),
                  expectedRevision: (f.retain(cancelled.snapshot())).revision(),
                  commands: [
                    native.StateCommand.view(
                        camera: const native.StateCamera(
                            view: _view, hasTrajectory: true),
                        adaptive: false)
                  ]),
          throwsA(anything));
      final invalid = native.StateOrbitPoint(x: double.nan, y: 0, z: 0);
      expect(
          () => native.StateTrajectorySettings(
              version: 1,
              integrator: 'rk4',
              system: native.StateAttractorSystem.thomas,
              seed: invalid,
              stepSize: 0.01,
              burnInSteps: 0,
              retainedSteps: 1,
              projection: native.StateOrbitProjection.thomasOblique),
          throwsA(anything));
      final edit = (await f.begin(s, active))!;
      final legacy = await f.apply(
          s,
          native.StateCommand.viewTrajectory(
              camera: native.StateTrajectoryCamera(view: _view),
              adaptive: false));
      expect(legacy.trajectory(), isNull);
      final edited = await s.advanceTrajectoryAsync(
          sessionId: legacy.sessionId(),
          expectedRevision: legacy.revision(),
          request: edit);
      f.progresses.add(edited);
      expect(edited.status(), native.StateTrajectoryStatus.cancelled);
      await s.shutdownAsync();
      await expectLater(s.snapshotAsync(), throwsA(anything));
      await expectLater(
          s.advanceTrajectoryAsync(
              sessionId: legacy.sessionId(),
              expectedRevision: legacy.revision(),
              request: edit),
          throwsA(anything));
      _compareFrame(retained, settings);
      _compareSettings(captured.trajectory()!, settings);
    }
  });
}
