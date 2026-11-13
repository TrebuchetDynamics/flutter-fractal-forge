// Compile-only fixture: native assertions remain unexecuted until official runs.
import 'dart:convert';
import 'dart:io';

// Fixture only: reuse flutter_test's already locked crypto dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_fractals/core/services/engine/rust_engine_adapter.dart';
import 'package:flutter_fractals/core/services/engine/rust_state_session_adapter.dart';
import 'package:flutter_fractals/core/services/engine/rust_state_session_backend_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as n;
import 'package:integration_test/integration_test.dart';

// Calculated from actual run_state_session_smoke.py --session projections.
const _projectedHashes = {
  'modules': '8176789bab9eeb2459bf2be0f60cc70318f3b33a7e2edaed66083b5fee147b39',
  'parameters':
      '6317622c1a5b517ea9acac7f0056aa3277e2942d34161bd03d9571276040c2b0',
  'presets': '972583d9991f557edc0ac362e74da73368f8109651cce700fb308b4d466754a3',
  'capabilities':
      '51b302655322d01383d378caf384977512eaff514bdc72fea3b22020f8490530',
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

void _accepted(SessionResult result) {
  expect(result.admission, SessionAdmission.accepted,
      reason: '${result.error}');
}

Future<SessionWorkRead> _terminal(
    RustStateSessionAdapter adapter, String operation) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  SessionResult? last;
  while (DateTime.now().isBefore(deadline)) {
    last = await adapter.poll().timeout(const Duration(seconds: 5),
        onTimeout: () => throw StateError(
            '$operation poll stalled: ${adapter.checkpoint?.data}'));
    _accepted(last);
    final work = last.work!;
    if (work.phase == StateWorkPhase.finished ||
        work.phase == StateWorkPhase.cancelled) {
      return work;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError(
      '$operation timed out: phase=${last?.work?.phase} error=${last?.error} checkpoint=${adapter.checkpoint?.data}');
}

const _view =
    StateView(zoom: 2, panX: 0.5, panY: -0.5, rotX: 0, rotY: 0, rotZ: 0);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'real whole Session transport, independent timelines and scheduled work',
      (tester) async {
    expect(const bool.fromEnvironment('RUST_CORE'), isTrue);
    expect(
        await RustStateSessionAdapter.create(
            loader: () async => throw StateError('default-off loaded')),
        isNull);
    final inputs = _inputs();
    final engine = (await RustEngineAdapter.create())!;
    addTearDown(engine.shutdown);
    expect(engine.rendering, isFalse);
    // Bind the library actually mapped by the future official native run.
    final mappings = File('/proc/self/maps')
        .readAsLinesSync()
        .where((line) => line.trim().endsWith('/libfractal_bridge.so'));
    expect(mappings, isNotEmpty);
    final library = mappings.first.trim().split(RegExp(r'\s+')).last;
    // ignore: avoid_print
    print(
        'Loaded Rust SO: $library sha256=${sha256.convert(File(library).readAsBytesSync())} rendering=${engine.rendering}');
    final service = n.StateWorkService();
    addTearDown(service.dispose);
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true,
        loader: () async => createRustStateSessionBackend(
            service: service,
            modules: inputs['modules']!,
            parameters: inputs['parameters']!,
            presets: inputs['presets']!,
            capabilities: inputs['capabilities']!,
            moduleId: 'mandelbrot')))!;
    addTearDown(adapter.dispose);
    final id = adapter.checkpoint!.sessionId;
    expect(id, isA<BigInt>());
    expect(adapter.checkpoint!.revision, BigInt.zero);
    Future<void> apply(SessionAction action) async {
      final before = adapter.checkpoint!;
      _accepted(await adapter.apply(action));
      expect(adapter.checkpoint!.sessionId, id);
      expect(
          adapter.checkpoint!.revision, greaterThanOrEqualTo(before.revision));
    }

    Future<void> commands(List<SessionCommand> values,
            {bool animate = false}) =>
        apply(SessionAction.commands(values, animate: animate));
    var sequence = BigInt.zero;
    Future<void> physical(List<SessionInput> values) =>
        apply(SessionAction.physical([
          for (final input in values)
            SessionEvent(
                sequence: sequence += BigInt.one,
                consumed: false,
                sourceUs: sequence.toInt() * 10000,
                input: input)
        ], viewport: const StateViewport(width: 400, height: 300)));
    final initialView = adapter.checkpoint!.data['view'] as StateView;
    await physical([SessionInput.wheel(localX: 200, localY: 150, dy: -120)]);
    expect((adapter.checkpoint!.data['view'] as StateView).zoom,
        greaterThan(initialView.zoom));
    SessionInput pointer(StatePointerPhase phase, double x) =>
        SessionInput.pointer(
            id: BigInt.parse('9007199254740993'),
            localX: x,
            localY: 150,
            phase: phase,
            kind: StatePointerKind.mouse,
            buttons: BigInt.one);
    final beforeDrag = adapter.checkpoint!.data['view'] as StateView;
    await physical([
      pointer(StatePointerPhase.down, 200),
      pointer(StatePointerPhase.move, 240),
      pointer(StatePointerPhase.up, 240)
    ]);
    expect((adapter.checkpoint!.data['view'] as StateView).panX,
        isNot(beforeDrag.panX));
    final generation = adapter.checkpoint!.data['physicalGeneration'] as BigInt;
    await physical([
      SessionInput.pump(generation: generation, deltaUs: 0),
      SessionInput.pump(generation: generation, deltaUs: 16000)
    ]);
    final lastGood = adapter.checkpoint;
    final rejected = await adapter.apply(SessionAction.commands(
        [SessionCommand.unsupported('native-fixture-rejection')]));
    expect(rejected.admission, SessionAdmission.rejected);
    expect(identical(adapter.checkpoint, lastGood), isTrue);

    await commands([SessionCommand.selectModule('julia', resetView: false)],
        animate: true);
    expect(adapter.morphToken, isNotNull);
    final morphProgress = adapter.checkpoint!.data['morphProgress'];
    await apply(SessionAction.startSeededParams(-42));
    final oldParam = adapter.paramToken;
    await apply(SessionAction.startSeededParams(-43));
    expect(identical(oldParam, adapter.paramToken), isFalse);
    expect(adapter.checkpoint!.data['morphProgress'], morphProgress);
    final param = adapter.paramToken!;
    final beforeTick = adapter.checkpoint!.revision;
    await apply(SessionAction.tickParams(param));
    expect(adapter.checkpoint!.revision, beforeTick + BigInt.one);
    expect(adapter.checkpoint!.data['isMorphing'], isTrue);
    await apply(SessionAction.cancelParams(param));
    await commands(
        [SessionCommand.selectModule('mandelbrot', resetView: false)],
        animate: true);
    expect(adapter.checkpoint!.data['previousModuleId'], 'julia');
    for (var i = 0; i < 36; i++) {
      await apply(SessionAction.tickMorph(adapter.morphToken!));
    }
    expect(adapter.checkpoint!.data['isMorphing'], isFalse);
    await commands([
      SessionCommand.load(
          moduleId: 'julia',
          params: {'iterations': const SessionValue.number('160')},
          view: _view,
          transparent: true),
      SessionCommand.glowEnabled(true),
      SessionCommand.glowSigma(2.5),
      SessionCommand.fluidStrength(0.25),
    ]);
    final loaded = adapter.checkpoint!;
    expect(((loaded.data['params'] as Map)['iterations'] as SessionValue).value,
        '160');
    expect(loaded.data['view'], _view);
    expect(loaded.data['transparentBackground'], isTrue);
    expect((loaded.data['effects'] as Map)['glowSigma'], 2.5);
    expect(loaded.hiddenOwners, isNotEmpty);
    expect(() => loaded.data['moduleId'] = 'bad', throwsUnsupportedError);

    // Wall module ingress itself is deferred; do not bypass the shared service.
    _accepted(await adapter.schedule(
        SessionWork.wall(SessionCommand.selectModule('number_wall', params: {
      'prime': const SessionValue.text('101'),
    }))));
    final wall = await _terminal(adapter, 'wall prime 101');
    expect(wall.phase, StateWorkPhase.finished);
    expect(wall.verifiedPrime, isTrue);
    expect(adapter.checkpoint!.data['numberWallFrame'], isNotNull);
    final retainedWall = adapter.checkpoint!;
    _accepted(await adapter
        .schedule(SessionWork.wall(SessionCommand.numberWallPrime('100'))));
    final composite = await _terminal(adapter, 'wall composite 100');
    expect(composite.verifiedPrime, isFalse);
    expect(composite.wallStatus, StateNumberWallStatus.composite);
    _accepted(await adapter.schedule(SessionWork.wall(
        SessionCommand.numberWallPrime(
            '170141183460469231731687303715884105727'),
        maxTrialDivisions: 1000000)));
    adapter.cancelWork();
    expect((await adapter.poll()).admission, SessionAdmission.rejected);

    await commands([SessionCommand.selectModule('thomas_attractor')]);
    _accepted(await adapter.schedule(const SessionWork.trajectory()));
    final trajectory = await _terminal(adapter, 'trajectory');
    expect(trajectory.phase, StateWorkPhase.finished);
    expect(adapter.checkpoint!.data['trajectoryStatus'],
        StateTrajectoryStatus.success);
    final frame = adapter.checkpoint!.data['trajectoryFrame'] as Map;
    expect(frame['sessionId'], id);
    expect(
        frame['settingsGeneration'], adapter.checkpoint!.trajectoryGeneration);
    expect(frame['points'], isNotEmpty);
    _accepted(await adapter.schedule(const SessionWork.trajectory()));
    adapter.cancelWork();
    expect((await adapter.poll()).admission, SessionAdmission.rejected);
    final retained = adapter.checkpoint!;
    await adapter.dispose();
    await adapter.dispose();
    expect((await adapter.refresh()).admission, SessionAdmission.closed);
    expect(identical(adapter.checkpoint, retained), isTrue);
    expect(loaded.data['view'], _view);
    expect(retainedWall.data['numberWallFrame'], isNotNull);
    expect(frame['points'], isNotEmpty);

    // Reuse existing fixed native u64 fixture outputs, not lossy double inputs.
    final source = n.StateSession(
        modules: inputs['modules']!,
        parameters: inputs['parameters']!,
        presets: inputs['presets']!,
        capabilities: inputs['capabilities']!,
        moduleId: 'mandelbrot');
    addTearDown(() async {
      await source.shutdownAsync();
      source.dispose();
    });
    final snapshot = await source.snapshotAsync();
    addTearDown(snapshot.dispose);
    final counters = snapshot.debugU64Fixtures();
    for (final counter in counters) {
      addTearDown(counter.dispose);
    }
    await source.shutdownAsync();
    expect(counters.map((s) => [s.sessionId(), s.revision()]), [
      [BigInt.parse('9007199254740993'), BigInt.parse('18446744073709551614')],
      [
        BigInt.parse('18446744073709551614'),
        BigInt.parse('18446744073709551615')
      ],
    ]);
  });
}
