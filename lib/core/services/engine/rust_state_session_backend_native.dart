import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as n;
import 'rust_state_session_backend.dart';

/// There is deliberately no implicit service or catalog owner.
Future<RustStateSessionBackend> loadRustStateSession() async =>
    throw StateError(
        'Inject a backend with a composition-owned StateWorkService');

/// The composition owner initializes FRB and retains/disposes [service].
/// This factory owns only the newly created Session.
RustStateSessionBackend createRustStateSessionBackend({
  required n.StateWorkService service,
  required String modules,
  required String parameters,
  required String presets,
  required String capabilities,
  required String moduleId,
}) =>
    _NativeBackend(
        n.StateSession(
            modules: modules,
            parameters: parameters,
            presets: presets,
            capabilities: capabilities,
            moduleId: moduleId),
        service);

/// Short-lived native return/argument handles, never detached presentation data.
class _Scope {
  final _dispose = <void Function()>[];
  T own<T>(T value) {
    _dispose.add(() => (value as dynamic).dispose());
    return value;
  }

  void close() {
    for (final dispose in _dispose.reversed) {
      dispose();
    }
  }
}

class _Token implements SessionToken {
  _Token(this.owner, this.value);
  final _NativeBackend owner;
  final dynamic value;
  bool closed = false;
  @override
  void close() {
    if (!closed) {
      closed = true;
      value.dispose();
    }
  }
}

class _NativeBackend implements RustStateSessionBackend {
  _NativeBackend(this.session, this.service);
  final n.StateSession session;
  final n.StateWorkService service;
  bool closed = false;
  dynamic _token(SessionToken? token) {
    if (token is! _Token || token.closed || !identical(token.owner, this)) {
      throw ArgumentError('Token is not owned by this Session');
    }
    return token.value;
  }

  @override
  Future<SessionReply> read() async => _detach(await session.snapshotAsync());

  @override
  Future<SessionReply> execute(
      SessionAction action, BigInt sessionId, BigInt revision) async {
    final scope = _Scope();
    try {
      switch (action.kind) {
        case SessionActionKind.commands:
          return _detach(await session.applyBatchWithModuleAnimation(
              sessionId: sessionId,
              expectedRevision: revision,
              commands: action.commands.map((c) => _command(c, scope)).toList(),
              animate: action.animate));
        case SessionActionKind.physical:
          final result = scope.own(await session.applyPhysicalAsync(
              sessionId: sessionId,
              expectedRevision: revision,
              viewport: action.viewport,
              events: action.events.map((e) => _event(e, scope)).toList()));
          return _detach(result.snapshot(),
              physicalGeneration: result.generation(),
              interactions: result.interactions(),
              keys: result.keys());
        case SessionActionKind.randomize:
          return _detach(await session.randomizeParams(
              sessionId: sessionId,
              expectedRevision: revision,
              seed: action.seed!));
        case SessionActionKind.startParams:
        case SessionActionKind.startSeededParams:
          final start = scope.own(action.kind == SessionActionKind.startParams
              ? await session.startParamTimeline(
                  sessionId: sessionId,
                  expectedRevision: revision,
                  target: action.target
                      .map((k, v) => MapEntry(k, _value(v, scope))))
              : await session.startSeededParamTimeline(
                  sessionId: sessionId,
                  expectedRevision: revision,
                  seed: action.seed!));
          final token = _Token(this, start.token());
          try {
            return _detach(start.snapshot(), paramToken: token);
          } catch (_) {
            token.close();
            rethrow;
          }
        case SessionActionKind.tickParams:
          return _detach(await session.tickParamTimeline(
              sessionId: sessionId,
              expectedRevision: revision,
              token: _token(action.token) as n.StateParamTimelineToken));
        case SessionActionKind.cancelParams:
          return _detach(await session.cancelParamTimeline(
              sessionId: sessionId,
              expectedRevision: revision,
              token: _token(action.token) as n.StateParamTimelineToken));
        case SessionActionKind.tickMorph:
          return _detach(await session.tickMorphTimeline(
              sessionId: sessionId,
              expectedRevision: revision,
              token: _token(action.token) as n.StateMorphTimelineToken));
        case SessionActionKind.cancelMorph:
          return _detach(await session.cancelMorphTimeline(
              sessionId: sessionId,
              expectedRevision: revision,
              token: _token(action.token) as n.StateMorphTimelineToken));
        case SessionActionKind.undoWall:
          final undo = scope.own(await session.undoNumberWallRandomization(
              sessionId: sessionId, expectedRevision: revision));
          return _detach(undo.snapshot());
      }
    } finally {
      scope.close();
    }
  }

  @override
  Future<SessionTicket> schedule(
      SessionWork work, BigInt sessionId, BigInt revision,
      {SessionTicket? replace}) async {
    final scope = _Scope();
    try {
      if (replace != null &&
          (replace is! _Ticket || !identical(replace.owner, this))) {
        throw ArgumentError('Foreign ticket');
      }
      final old = (replace as _Ticket?)?.ticket;
      final command = work.command;
      final ticket = command == null
          ? old == null
              ? service.submitTrajectory(
                  session: session,
                  sessionId: sessionId,
                  expectedRevision: revision)
              : service.replaceTrajectory(
                  session: session,
                  sessionId: sessionId,
                  expectedRevision: revision,
                  replace: old)
          : old == null
              ? service.submitNumberWall(
                  session: session,
                  sessionId: sessionId,
                  expectedRevision: revision,
                  command: _command(command, scope),
                  maxTrialDivisions: work.maxTrialDivisions)
              : service.replaceNumberWall(
                  session: session,
                  sessionId: sessionId,
                  expectedRevision: revision,
                  command: _command(command, scope),
                  maxTrialDivisions: work.maxTrialDivisions,
                  replace: old);
      return _Ticket(this, ticket);
    } finally {
      scope.close();
    }
  }

  @override
  Future<void> close() async {
    if (closed) return;
    closed = true;
    try {
      await session.shutdownAsync();
    } finally {
      session.dispose();
    }
  }

  SessionReply _detach(n.StateSnapshot snapshot,
      {SessionToken? paramToken,
      BigInt? physicalGeneration,
      List<n.StateInteraction> interactions = const [],
      List<n.StateKeyDisposition> keys = const []}) {
    final scope = _Scope()..own(snapshot);
    _Token? morph;
    try {
      final morphHandle = snapshot.morphTimelineToken();
      if (morphHandle != null) morph = _Token(this, morphHandle);
      final trajectory = snapshot.trajectory();
      final wall = snapshot.numberWallFrame();
      final frame = snapshot.trajectoryFrame();
      if (trajectory != null) scope.own(trajectory);
      if (wall != null) scope.own(wall);
      if (frame != null) scope.own(frame);
      physicalGeneration ??= session.physicalGeneration();
      final id = snapshot.sessionId();
      final generation = snapshot.trajectoryGeneration();
      // A frame from a previous settings generation is not presentation state.
      final validFrame = frame != null &&
          frame.sessionId() == id &&
          frame.settingsGeneration() == generation;
      final hidden = <String>{
        if (paramToken != null) 'parameter timeline token',
        if (morph != null) 'morph timeline token',
        if (snapshot.numberWallPending()) 'number-wall request/service ticket',
        if (snapshot.trajectoryPending()) 'trajectory request/service ticket',
        'physical input/pump state (Session-owned)',
        'randomization undo state (Session-owned)',
        'parameter timeline target/progress (Session-owned; may be active)',
      };
      return SessionReply(
          SessionCheckpoint(
              sessionId: id,
              revision: snapshot.revision(),
              trajectoryGeneration: generation,
              hiddenOwners: hidden,
              data: {
                'physicalGeneration': physicalGeneration,
                'moduleId': snapshot.moduleId(),
                'params': _params(snapshot.params(), scope),
                'view': snapshot.view(),
                'trajectory': trajectory == null ? null : _settings(trajectory),
                'transparentBackground': snapshot.transparentBackground(),
                'rotationLocked': snapshot.rotationLocked(),
                'lastAdaptiveZoom': snapshot.lastAdaptiveZoom(),
                'effects': {
                  'fluidModeEnabled': snapshot.fluidModeEnabled(),
                  'fluidStrength': snapshot.fluidStrength(),
                  'glowEnabled': snapshot.glowEnabled(),
                  'glowIntensity': snapshot.glowIntensity(),
                  'glowSigma': snapshot.glowSigma(),
                  'kaleidoscopeEnabled': snapshot.kaleidoscopeEnabled(),
                  'kaleidoscopeMirror': snapshot.kaleidoscopeMirror(),
                  'kaleidoscopeMirrorMode': snapshot.kaleidoscopeMirrorMode(),
                  'kaleidoscopeRotation': snapshot.kaleidoscopeRotation(),
                  'kaleidoscopeSectors': snapshot.kaleidoscopeSectors(),
                },
                'isMorphing': snapshot.isMorphing(),
                'morphProgress': snapshot.morphProgress(),
                'previousModuleId': snapshot.previousModuleId(),
                'canUndoNumberWallRandomization':
                    snapshot.canUndoNumberWallRandomization(),
                'numberWallPending': snapshot.numberWallPending(),
                'numberWallStatus': snapshot.numberWallStatus(),
                'trajectoryPending': snapshot.trajectoryPending(),
                'trajectoryStatus': snapshot.trajectoryStatus(),
                'numberWallFrame': wall == null
                    ? null
                    : {
                        'params': _params(wall.params(), scope),
                        'modulus': wall.modulus(),
                        'sequence': wall.sequence(),
                        'columnCount': wall.columnCount(),
                        'columnStart': wall.columnStart(),
                        'rowCount': wall.rowCount(),
                        'supportStart': wall.supportStart(),
                        'supportEnd': wall.supportEnd(),
                        'values': wall.values(),
                      },
                'trajectoryFrame': !validFrame
                    ? null
                    : {
                        'sessionId': frame.sessionId(),
                        'settingsGeneration': frame.settingsGeneration(),
                        'moduleId': frame.moduleId(),
                        'settings': _settings(scope.own(frame.settings())),
                        'points': frame.points(),
                        'bounds': frame.bounds(),
                        'cacheHit': frame.cacheHit(),
                      },
              }),
          paramToken: paramToken,
          morphToken: morph,
          physicalGeneration: physicalGeneration,
          interactions: interactions,
          keys: keys);
    } catch (_) {
      morph?.close();
      rethrow;
    } finally {
      scope.close();
    }
  }
}

class _Ticket implements SessionTicket {
  _Ticket(this.owner, this.ticket);
  final _NativeBackend owner;
  final n.StateWorkTicket ticket;
  bool closed = false;
  @override
  Future<SessionWorkRead> read() async {
    if (closed) throw StateError('Ticket closed');
    final status = ticket.status();
    return SessionWorkRead(status.phase,
        error: status.error,
        wallStatus: status.wallStatus,
        stepsCompleted: status.stepsCompleted,
        reply:
            status.snapshot == null ? null : owner._detach(status.snapshot!));
  }

  @override
  void close() {
    if (closed) return;
    closed = true;
    try {
      ticket.cancel();
    } finally {
      ticket.dispose();
    }
  }
}

SessionTrajectorySettings _settings(n.StateTrajectorySettings s) =>
    SessionTrajectorySettings(
        version: s.version(),
        integrator: s.integrator(),
        system: s.system(),
        seed: s.seed(),
        stepSize: s.stepSize(),
        burnInSteps: s.burnInSteps(),
        retainedSteps: s.retainedSteps(),
        projection: s.projection());
Map<String, SessionValue> _params(
        Map<String, n.StateValue> values, _Scope scope) =>
    values.map((key, value) {
      scope.own(value);
      final number = value.number();
      final text = value.text();
      final boolean = value.boolean();
      return MapEntry(
          key,
          number != null
              ? SessionValue.number(number)
              : text != null
                  ? SessionValue.text(text)
                  : boolean != null
                      ? SessionValue.boolean(boolean)
                      : SessionValue.float(value.float()!));
    });
n.StateValue _value(SessionValue value, _Scope scope) =>
    scope.own(switch (value.kind) {
      SessionValueKind.number =>
        n.StateValue.fromNumber(value: value.value as String),
      SessionValueKind.text =>
        n.StateValue.fromText(value: value.value as String),
      SessionValueKind.boolean =>
        n.StateValue.fromBoolean(value: value.value as bool),
      SessionValueKind.float =>
        n.StateValue.fromFloat(value: value.value as double),
    });

n.StateTrajectorySettings _trajectory(
        SessionTrajectorySettings s, _Scope scope) =>
    scope.own(n.StateTrajectorySettings(
        version: s.version,
        integrator: s.integrator,
        system: s.system,
        seed: s.seed,
        stepSize: s.stepSize,
        burnInSteps: s.burnInSteps,
        retainedSteps: s.retainedSteps,
        projection: s.projection));

n.StateCommand _command(SessionCommand command, _Scope scope) {
  final d = command.data;
  T get<T>(String key) => d[key] as T;
  Map<String, n.StateValue> params() =>
      (d['params'] as Map<String, Object?>? ?? {})
          .map((k, v) => MapEntry(k, _value(v as SessionValue, scope)));
  n.StateTrajectoryCamera camera() => scope.own(n.StateTrajectoryCamera(
      view: get<n.StateView>('view'),
      trajectory: d['trajectory'] == null
          ? null
          : _trajectory(get<SessionTrajectorySettings>('trajectory'), scope)));
  return scope.own(switch (command.kind) {
    SessionCommandKind.param =>
      n.StateCommand.param(id: get('id'), value: _value(get('value'), scope)),
    SessionCommandKind.selectModule => n.StateCommand.selectModule(
        moduleId: get('moduleId'),
        resetView: get('resetView'),
        initialParams: params()),
    SessionCommandKind.applyPreset => n.StateCommand.applyPresetTrajectory(
        moduleId: get('moduleId'), params: params(), camera: camera()),
    SessionCommandKind.load => n.StateCommand.loadTrajectory(
        moduleId: d['moduleId'] as String?,
        params: params(),
        camera: camera(),
        transparent: get('transparent')),
    SessionCommandKind.view => n.StateCommand.viewTrajectory(
        camera: camera(), adaptive: get('adaptive')),
    SessionCommandKind.resetParams => n.StateCommand.resetParams(),
    SessionCommandKind.resetSession => n.StateCommand.resetSession(),
    SessionCommandKind.resetView => n.StateCommand.resetView(),
    SessionCommandKind.zoom => n.StateCommand.zoom(value: get('value')),
    SessionCommandKind.pan => n.StateCommand.pan(x: get('x'), y: get('y')),
    SessionCommandKind.rotation =>
      n.StateCommand.rotation(x: get('x'), y: get('y'), z: get('z')),
    SessionCommandKind.rotationLocked =>
      n.StateCommand.rotationLocked(value: get('value')),
    SessionCommandKind.transparent =>
      n.StateCommand.transparent(value: get('value')),
    SessionCommandKind.numberWallPrime =>
      n.StateCommand.numberWallPrime(value: get('value')),
    SessionCommandKind.fluidModeEnabled =>
      n.StateCommand.fluidModeEnabled(value: get('value')),
    SessionCommandKind.fluidStrength =>
      n.StateCommand.fluidStrength(value: get('value')),
    SessionCommandKind.glowEnabled =>
      n.StateCommand.glowEnabled(value: get('value')),
    SessionCommandKind.glowIntensity =>
      n.StateCommand.glowIntensity(value: get('value')),
    SessionCommandKind.glowSigma =>
      n.StateCommand.glowSigma(value: get('value')),
    SessionCommandKind.kaleidoscopeEnabled =>
      n.StateCommand.kaleidoscopeEnabled(value: get('value')),
    SessionCommandKind.kaleidoscopeMirror =>
      n.StateCommand.kaleidoscopeMirror(value: get('value')),
    SessionCommandKind.kaleidoscopeMirrorMode =>
      n.StateCommand.kaleidoscopeMirrorMode(value: get('value')),
    SessionCommandKind.kaleidoscopeRotation =>
      n.StateCommand.kaleidoscopeRotation(value: get('value')),
    SessionCommandKind.kaleidoscopeSectors =>
      n.StateCommand.kaleidoscopeSectors(value: get('value')),
    SessionCommandKind.unsupported =>
      n.StateCommand.unsupported(operation: get('operation')),
  });
}

n.StatePhysicalEvent _event(SessionEvent event, _Scope scope) {
  T get<T>(String key) => event.data[key] as T;
  final input = scope.own(switch (event.kind) {
    SessionInputKind.wheel => n.StatePhysicalInput.wheel(
        localX: get('localX'), localY: get('localY'), dy: get('dy')),
    SessionInputKind.pointer => n.StatePhysicalInput.pointer(
        id: get('id'),
        localX: get('localX'),
        localY: get('localY'),
        phase: get('phase'),
        kind: get('kind'),
        buttons: get('buttons')),
    SessionInputKind.key =>
      n.StatePhysicalInput.key(key: get('key'), phase: get('phase')),
    SessionInputKind.focus => n.StatePhysicalInput.focus(focus: get('focus')),
    SessionInputKind.pump => n.StatePhysicalInput.pump(
        generation: get('generation'), deltaUs: get('deltaUs')),
    SessionInputKind.wall => n.StatePhysicalInput.wall(us: get('us')),
    SessionInputKind.disposeInput => n.StatePhysicalInput.disposeInput(),
  });
  return scope.own(n.StatePhysicalEvent(
      sequence: event.sequence,
      sourceUs: event.sourceUs,
      consumed: event.consumed,
      input: input));
}
