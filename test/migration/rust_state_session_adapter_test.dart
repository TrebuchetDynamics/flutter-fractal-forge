import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/engine/rust_state_session_adapter.dart';

SessionCheckpoint snapshot(int revision,
        {int session = 1, int generation = 0}) =>
    SessionCheckpoint(
        sessionId: BigInt.from(session),
        revision: BigInt.from(revision),
        trajectoryGeneration: BigInt.from(generation),
        data: {
          'moduleId': 'number_wall',
          'params': {'prime': const SessionValue.number('9007199254740993')},
          'transparentBackground': true,
          'effects': {'glowEnabled': true},
          'view': {'zoom': 2.0},
          'trajectory': {'integrator': 'rk4'},
          'morphProgress': 0.5,
          'numberWallFrame': {
            'values': [
              ['9007199254740993']
            ]
          },
          'numberWallStatus': StateNumberWallStatus.composite,
        });

class FakeBackend implements RustStateSessionBackend {
  Completer<SessionReply>? pending;
  final calls = <SessionAction>[];
  final owners = <(BigInt, BigInt)>[];
  int closes = 0, schedules = 0;
  Object? error;
  SessionReply? response;
  SessionTicket? replaced;
  Completer<SessionTicket>? pendingSchedule;
  FakeTicket ticket = FakeTicket();
  @override
  Future<SessionReply> execute(
      SessionAction action, BigInt id, BigInt revision) async {
    calls.add(action);
    owners.add((id, revision));
    if (pending != null) return await pending!.future;
    if (error != null) throw error!;
    return response ?? SessionReply(snapshot(1));
  }

  @override
  Future<SessionReply> read() async => response ?? SessionReply(snapshot(0));
  @override
  Future<SessionTicket> schedule(SessionWork work, BigInt id, BigInt revision,
      {SessionTicket? replace}) async {
    schedules++;
    replaced = replace;
    return pendingSchedule == null ? ticket : await pendingSchedule!.future;
  }

  @override
  Future<void> close() async {
    closes++;
  }
}

class FakeTicket implements SessionTicket {
  int closes = 0;
  Completer<SessionWorkRead>? pending;
  SessionWorkRead value = const SessionWorkRead(StateWorkPhase.finished,
      wallStatus: StateNumberWallStatus.composite);
  @override
  Future<SessionWorkRead> read() async =>
      pending == null ? value : await pending!.future;
  @override
  void close() {
    closes++;
  }
}

class FakeToken implements SessionToken {
  int closes = 0;
  @override
  void close() {
    closes++;
  }
}

void main() {
  test('default-off and Web refusal do not load a backend', () async {
    var loads = 0;
    Future<RustStateSessionBackend> load() async {
      loads++;
      return FakeBackend();
    }

    expect(await RustStateSessionAdapter.create(loader: load), isNull);
    expect(
        await RustStateSessionAdapter.create(
            enabled: true, isWeb: true, loader: load),
        isNull);
    expect(loads, 0);
  });

  test('Busy admits no input; late disposal releases response owners',
      () async {
    final backend = FakeBackend()..pending = Completer<SessionReply>();
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true, loader: () async => backend))!;
    final action = SessionAction.commands([
      SessionCommand.param(
          'prime', const SessionValue.number('9007199254740993'))
    ]);
    final first = adapter.apply(action);
    expect((await adapter.apply(action)).admission, SessionAdmission.busy);
    expect(backend.calls, [action]);
    backend.pending!.complete(SessionReply(snapshot(1)));
    expect((await first).admission, SessionAdmission.accepted);
    backend.pending = Completer<SessionReply>();
    final retry = adapter.apply(action);
    expect(backend.calls, [action, action]);
    await adapter.dispose();
    final owner = FakeToken();
    backend.pending!.complete(SessionReply(snapshot(1), paramToken: owner));
    expect((await retry).admission, SessionAdmission.closed);
    expect(adapter.checkpoint!.revision, BigInt.one);
    expect(owner.closes, 1);
    await adapter.dispose();
    expect(backend.closes, 1);
  });

  test(
      'ordered editor/preset/load/history/deep-link commands and raw events stay exact',
      () async {
    final backend = FakeBackend();
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true, loader: () async => backend))!;
    const view =
        StateView(zoom: 1, panX: 0, panY: 0, rotX: 0, rotY: 0, rotZ: 0);
    final commands = [
      SessionCommand.param(
          'prime', const SessionValue.number('9007199254740993')),
      SessionCommand.selectModule('julia'),
      SessionCommand.applyPreset('julia',
          params: {'label': const SessionValue.text('9007199254740993')},
          view: view),
      // Decoded history and deep-link inputs use the same load seam, not live stores.
      for (final source in ['history', 'deep-link'])
        SessionCommand.load(
            moduleId: 'julia',
            params: {'label': SessionValue.text(source)},
            view: view,
            transparent: true),
    ];
    final action = SessionAction.commands(commands);
    expect((await adapter.apply(action)).admission, SessionAdmission.accepted);
    expect(backend.calls.single, same(action));
    expect(action.commands, orderedEquals(commands));
    final event = SessionEvent(
        sequence: BigInt.parse('18446744073709551614'),
        consumed: false,
        input: SessionInput.pump(
            generation: BigInt.parse('9007199254740993'), deltaUs: 123));
    await adapter.apply(SessionAction.physical([event]));
    expect(backend.calls.last.events.single, same(event));
    final token = FakeToken();
    await adapter.apply(SessionAction.tickParams(token));
    expect(backend.calls.last.token, same(token));
    backend.error = UnsupportedError('operation not supported');
    final lastGood = adapter.checkpoint;
    expect(
        (await adapter.apply(SessionAction.commands(
                [SessionCommand.unsupported('capture')])))
            .admission,
        SessionAdmission.rejected);
    expect(adapter.checkpoint, same(lastGood));
    await adapter.dispose();
  });

  test(
      'wrong owner/older revision/frame generation cannot publish; equal reads can',
      () async {
    final backend = FakeBackend();
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true, loader: () async => backend))!;
    backend.response = SessionReply(snapshot(4, generation: 2));
    await adapter.refresh();
    for (final bad in [
      snapshot(5, session: 2, generation: 2),
      snapshot(3, generation: 2),
      snapshot(5, generation: 1),
      SessionCheckpoint(
          sessionId: BigInt.one,
          revision: BigInt.from(5),
          trajectoryGeneration: BigInt.two,
          data: {
            'trajectoryFrame': {
              'sessionId': BigInt.one,
              'settingsGeneration': BigInt.one
            }
          })
    ]) {
      final token = FakeToken();
      backend.response = SessionReply(bad, morphToken: token);
      expect((await adapter.refresh()).admission, SessionAdmission.rejected);
      expect(adapter.checkpoint!.revision, BigInt.from(4));
      expect(token.closes, 1);
    }
    backend.response = SessionReply(snapshot(4, generation: 2));
    expect((await adapter.refresh()).admission, SessionAdmission.accepted);
    await adapter.dispose();
  });

  test('checkpoint stays deeply detached and exact after close', () async {
    final backend = FakeBackend();
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true, loader: () async => backend))!;
    final data = <String, Object?>{
      'text': const SessionValue.text('01'),
      'enum': StateNumberWallStatus.composite
    };
    final original = snapshot(1);
    backend.response = SessionReply(SessionCheckpoint(
        sessionId: BigInt.one,
        revision: BigInt.parse('18446744073709551614'),
        trajectoryGeneration: BigInt.zero,
        data: {...original.data, 'exact': data},
        hiddenOwners: {'physical input/pump state (Session-owned)'}));
    await adapter.refresh();
    data['text'] = const SessionValue.text('changed');
    final retained = adapter.checkpoint!;
    await adapter.apply(SessionAction.commands([]));
    expect(backend.owners.last, (BigInt.one, retained.revision));
    final afterRead = adapter.checkpoint!;
    await adapter.dispose();
    expect(adapter.checkpoint, same(afterRead));
    expect(retained.revision.toString(), '18446744073709551614');
    expect(
        ((retained.data['exact'] as Map)['text'] as SessionValue).value, '01');
    expect(
        retained.data.keys,
        containsAll([
          'moduleId',
          'params',
          'view',
          'trajectory',
          'effects',
          'transparentBackground',
          'morphProgress',
          'numberWallFrame',
          'numberWallStatus'
        ]));
    expect(retained.hiddenOwners, isNotEmpty);
    expect(() => (retained.data['effects'] as Map)['glowEnabled'] = false,
        throwsUnsupportedError);
    expect(
        () => ((retained.data['numberWallFrame'] as Map)['values'] as List)
            .clear(),
        throwsUnsupportedError);
  });

  test(
      'one borrowed service route replaces/cancels tickets; Finished is not prime',
      () async {
    final backend = FakeBackend();
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true, loader: () async => backend))!;
    final first = backend.ticket;
    expect((await adapter.schedule(const SessionWork.trajectory())).admission,
        SessionAdmission.accepted);
    expect((await adapter.poll()).work!.verifiedPrime, isFalse);
    first.value = const SessionWorkRead(StateWorkPhase.finished,
        wallStatus: StateNumberWallStatus.verifiedPrime);
    expect((await adapter.poll()).work!.verifiedPrime, isTrue);
    final lastGood = adapter.checkpoint;
    first.value = SessionWorkRead(StateWorkPhase.failed,
        error: 'failed', reply: SessionReply(snapshot(9)));
    expect((await adapter.poll()).admission, SessionAdmission.rejected);
    expect(adapter.checkpoint, same(lastGood));
    backend.ticket = FakeTicket();
    await adapter
        .schedule(SessionWork.wall(SessionCommand.numberWallPrime('17')));
    expect(backend.replaced, same(first));
    expect(first.closes, 1);
    adapter.cancelWork();
    await adapter.dispose();
    expect(backend.ticket.closes, 1);
    expect(backend.schedules, 2);
    expect(backend.calls, isEmpty);
  });

  test('timeline replace/cancel/dispose releases owned tokens once', () async {
    final backend = FakeBackend();
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true, loader: () async => backend))!;
    final params = FakeToken(), morph = FakeToken(), replacement = FakeToken();
    backend.response =
        SessionReply(snapshot(1), paramToken: params, morphToken: morph);
    await adapter.apply(SessionAction.startSeededParams(7));
    backend.response = SessionReply(snapshot(2), paramToken: replacement);
    await adapter
        .apply(SessionAction.startParams({'x': const SessionValue.float(1)}));
    expect(params.closes, 1);
    expect(morph.closes, 1);
    backend.response = SessionReply(snapshot(3));
    await adapter.apply(SessionAction.cancelParams(replacement));
    expect(replacement.closes, 1);
    await adapter.dispose();
    expect([params.closes, morph.closes, replacement.closes], [1, 1, 1]);
  });

  test(
      'cancelled generation and post-close delayed ticket results never publish',
      () async {
    for (final dispose in [false, true]) {
      final backend = FakeBackend();
      final adapter = (await RustStateSessionAdapter.create(
          enabled: true, loader: () async => backend))!;
      await adapter.schedule(const SessionWork.trajectory());
      backend.ticket.pending = Completer<SessionWorkRead>();
      final poll = adapter.poll();
      if (dispose) {
        await adapter.dispose();
      } else {
        adapter.cancelWork();
      }
      final token = FakeToken();
      backend.ticket.pending!.complete(SessionWorkRead(StateWorkPhase.finished,
          reply: SessionReply(snapshot(7), morphToken: token)));
      expect((await poll).admission,
          dispose ? SessionAdmission.closed : SessionAdmission.rejected);
      expect(adapter.checkpoint!.revision, BigInt.zero);
      expect(token.closes, 1);
      await adapter.dispose();
      expect(backend.ticket.closes, 1);
    }
    final backend = FakeBackend()..pendingSchedule = Completer<SessionTicket>();
    final adapter = (await RustStateSessionAdapter.create(
        enabled: true, loader: () async => backend))!;
    final scheduling = adapter.schedule(const SessionWork.trajectory());
    await adapter.dispose();
    backend.pendingSchedule!.complete(backend.ticket);
    expect((await scheduling).admission, SessionAdmission.closed);
    expect(backend.ticket.closes, 1);
  });
}
