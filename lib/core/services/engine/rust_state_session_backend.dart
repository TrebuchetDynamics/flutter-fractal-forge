import 'package:fractal_engine_bridge/fractal_engine_bridge.dart';
export 'package:fractal_engine_bridge/fractal_engine_bridge.dart'
    show
        StateWorkPhase,
        StateNumberWallStatus,
        StateTrajectoryStatus,
        StateFocus,
        StateKey,
        StateKeyPhase,
        StatePointerKind,
        StatePointerPhase,
        StateViewport,
        StateView,
        StateOrbitProjection,
        StateAttractorSystem,
        StateOrbitPoint,
        StateOrbitBounds;

/// Exact JSON numbers remain distinct from text; neither is parsed as a double.
class SessionValue {
  const SessionValue.number(String this.value) : kind = SessionValueKind.number;
  const SessionValue.text(String this.value) : kind = SessionValueKind.text;
  const SessionValue.boolean(bool this.value) : kind = SessionValueKind.boolean;
  const SessionValue.float(double this.value) : kind = SessionValueKind.float;
  final SessionValueKind kind;
  final Object value;
}

enum SessionValueKind { number, text, boolean, float }

class SessionTrajectorySettings {
  const SessionTrajectorySettings(
      {required this.version,
      required this.integrator,
      required this.system,
      required this.seed,
      required this.stepSize,
      required this.burnInSteps,
      required this.retainedSteps,
      required this.projection});
  final int version;
  final String integrator;
  final StateAttractorSystem system;
  final StateOrbitPoint seed;
  final double stepSize;
  final int burnInSteps, retainedSteps;
  final StateOrbitProjection projection;
}

/// Only detached immutable bridge values are admitted to the presentation tree.
Object? _freeze(Object? value) {
  if (value is Map<String, Object?>) {
    return Map<String, Object?>.unmodifiable(
        value.map((k, v) => MapEntry(k, _freeze(v))));
  }
  if (value is List) return List<Object?>.unmodifiable(value.map(_freeze));
  if (value == null ||
      value is String ||
      value is num ||
      value is bool ||
      value is BigInt ||
      value is Enum ||
      value is SessionValue ||
      value is SessionTrajectorySettings ||
      value is StateView ||
      value is StateOrbitPoint ||
      value is StateOrbitBounds) return value;
  throw ArgumentError('Not a detached session value: ${value.runtimeType}');
}

Map<String, Object?> freezeSessionData(Map<String, Object?> data) =>
    _freeze(data)! as Map<String, Object?>;

/// Complete supported read tree, not FractalPreset JSON or a restorable engine.
class SessionCheckpoint {
  SessionCheckpoint(
      {required this.sessionId,
      required this.revision,
      required this.trajectoryGeneration,
      required Map<String, Object?> data,
      Set<String> hiddenOwners = const {}})
      : data = freezeSessionData(data),
        hiddenOwners = Set.unmodifiable(hiddenOwners);
  final BigInt sessionId;
  final BigInt revision;
  final BigInt trajectoryGeneration;
  final Map<String, Object?> data;
  final Set<String> hiddenOwners;
  SessionCheckpoint._(this.sessionId, this.revision, this.trajectoryGeneration,
      this.data, this.hiddenOwners);
  SessionCheckpoint withHiddenOwners(Iterable<String> owners) =>
      SessionCheckpoint._(sessionId, revision, trajectoryGeneration, data,
          Set.unmodifiable(owners));
}

enum SessionCommandKind {
  param,
  selectModule,
  applyPreset,
  load,
  resetParams,
  resetSession,
  resetView,
  view,
  zoom,
  pan,
  rotation,
  rotationLocked,
  transparent,
  numberWallPrime,
  fluidModeEnabled,
  fluidStrength,
  glowEnabled,
  glowIntensity,
  glowSigma,
  kaleidoscopeEnabled,
  kaleidoscopeMirror,
  kaleidoscopeMirrorMode,
  kaleidoscopeRotation,
  kaleidoscopeSectors,
  unsupported,
}

class SessionCommand {
  SessionCommand._(this.kind, [Map<String, Object?> data = const {}])
      : data = freezeSessionData(data);
  SessionCommand.param(String id, SessionValue value)
      : this._(SessionCommandKind.param, {'id': id, 'value': value});
  SessionCommand.selectModule(String moduleId,
      {bool resetView = true, Map<String, SessionValue> params = const {}})
      : this._(SessionCommandKind.selectModule,
            {'moduleId': moduleId, 'resetView': resetView, 'params': params});
  SessionCommand.applyPreset(String moduleId,
      {required Map<String, SessionValue> params,
      required StateView view,
      SessionTrajectorySettings? trajectory})
      : this._(SessionCommandKind.applyPreset, {
          'moduleId': moduleId,
          'params': params,
          'view': view,
          'trajectory': trajectory
        });
  SessionCommand.load(
      {String? moduleId,
      required Map<String, SessionValue> params,
      required StateView view,
      SessionTrajectorySettings? trajectory,
      required bool transparent})
      : this._(SessionCommandKind.load, {
          'moduleId': moduleId,
          'params': params,
          'view': view,
          'trajectory': trajectory,
          'transparent': transparent
        });
  SessionCommand.view(StateView view,
      {SessionTrajectorySettings? trajectory, required bool adaptive})
      : this._(SessionCommandKind.view,
            {'view': view, 'trajectory': trajectory, 'adaptive': adaptive});
  SessionCommand.resetParams() : this._(SessionCommandKind.resetParams);
  SessionCommand.resetSession() : this._(SessionCommandKind.resetSession);
  SessionCommand.resetView() : this._(SessionCommandKind.resetView);
  SessionCommand.zoom(double value)
      : this._(SessionCommandKind.zoom, {'value': value});
  SessionCommand.pan(double x, double y)
      : this._(SessionCommandKind.pan, {'x': x, 'y': y});
  SessionCommand.rotation(double x, double y, double z)
      : this._(SessionCommandKind.rotation, {'x': x, 'y': y, 'z': z});
  SessionCommand.rotationLocked(bool value)
      : this._(SessionCommandKind.rotationLocked, {'value': value});
  SessionCommand.transparent(bool value)
      : this._(SessionCommandKind.transparent, {'value': value});
  SessionCommand.numberWallPrime(String value)
      : this._(SessionCommandKind.numberWallPrime, {'value': value});
  SessionCommand.fluidModeEnabled(bool value)
      : this._(SessionCommandKind.fluidModeEnabled, {'value': value});
  SessionCommand.fluidStrength(double value)
      : this._(SessionCommandKind.fluidStrength, {'value': value});
  SessionCommand.glowEnabled(bool value)
      : this._(SessionCommandKind.glowEnabled, {'value': value});
  SessionCommand.glowIntensity(double value)
      : this._(SessionCommandKind.glowIntensity, {'value': value});
  SessionCommand.glowSigma(double value)
      : this._(SessionCommandKind.glowSigma, {'value': value});
  SessionCommand.kaleidoscopeEnabled(bool value)
      : this._(SessionCommandKind.kaleidoscopeEnabled, {'value': value});
  SessionCommand.kaleidoscopeMirror(bool value)
      : this._(SessionCommandKind.kaleidoscopeMirror, {'value': value});
  SessionCommand.kaleidoscopeMirrorMode(int value)
      : this._(SessionCommandKind.kaleidoscopeMirrorMode, {'value': value});
  SessionCommand.kaleidoscopeRotation(double value)
      : this._(SessionCommandKind.kaleidoscopeRotation, {'value': value});
  SessionCommand.kaleidoscopeSectors(int value)
      : this._(SessionCommandKind.kaleidoscopeSectors, {'value': value});
  SessionCommand.unsupported(String operation)
      : this._(SessionCommandKind.unsupported, {'operation': operation});
  final SessionCommandKind kind;
  final Map<String, Object?> data;
}

enum SessionInputKind { wheel, pointer, key, focus, pump, wall, disposeInput }

class SessionInput {
  SessionInput._(this.kind, Map<String, Object?> data)
      : data = freezeSessionData(data);
  SessionInput.wheel(
      {required double localX, required double localY, required double dy})
      : this._(SessionInputKind.wheel,
            {'localX': localX, 'localY': localY, 'dy': dy});
  SessionInput.pointer(
      {required BigInt id,
      required double localX,
      required double localY,
      required StatePointerPhase phase,
      required StatePointerKind kind,
      required BigInt buttons})
      : this._(SessionInputKind.pointer, {
          'id': id,
          'localX': localX,
          'localY': localY,
          'phase': phase,
          'kind': kind,
          'buttons': buttons
        });
  SessionInput.key(StateKey key, StateKeyPhase phase)
      : this._(SessionInputKind.key, {'key': key, 'phase': phase});
  SessionInput.focus(StateFocus focus)
      : this._(SessionInputKind.focus, {'focus': focus});
  SessionInput.pump({required BigInt generation, required int deltaUs})
      : this._(SessionInputKind.pump,
            {'generation': generation, 'deltaUs': deltaUs});
  SessionInput.wall(int us) : this._(SessionInputKind.wall, {'us': us});
  SessionInput.disposeInput() : this._(SessionInputKind.disposeInput, {});
  final SessionInputKind kind;
  final Map<String, Object?> data;
}

class SessionEvent {
  const SessionEvent(
      {required this.sequence,
      this.sourceUs,
      required this.consumed,
      required this.input});
  final BigInt sequence;
  final int? sourceUs;
  final bool consumed;
  final SessionInput input;
  SessionInputKind get kind => input.kind;
  Map<String, Object?> get data => input.data;
}

enum SessionActionKind {
  commands,
  physical,
  randomize,
  startParams,
  startSeededParams,
  tickParams,
  cancelParams,
  tickMorph,
  cancelMorph,
  undoWall
}

class SessionAction {
  SessionAction.commands(List<SessionCommand> commands, {this.animate = false})
      : kind = SessionActionKind.commands,
        commands = List.unmodifiable(commands),
        events = const [],
        viewport = null,
        seed = null,
        target = const {},
        token = null;
  SessionAction.physical(List<SessionEvent> events, {this.viewport})
      : kind = SessionActionKind.physical,
        events = List.unmodifiable(events),
        commands = const [],
        animate = false,
        seed = null,
        target = const {},
        token = null;
  SessionAction.randomize(int seed)
      : this._timeline(SessionActionKind.randomize, seed: seed);
  SessionAction.startParams(Map<String, SessionValue> target)
      : this._timeline(SessionActionKind.startParams, target: target);
  SessionAction.startSeededParams(int seed)
      : this._timeline(SessionActionKind.startSeededParams, seed: seed);
  SessionAction.tickParams(SessionToken token)
      : this._timeline(SessionActionKind.tickParams, token: token);
  SessionAction.cancelParams(SessionToken token)
      : this._timeline(SessionActionKind.cancelParams, token: token);
  SessionAction.tickMorph(SessionToken token)
      : this._timeline(SessionActionKind.tickMorph, token: token);
  SessionAction.cancelMorph(SessionToken token)
      : this._timeline(SessionActionKind.cancelMorph, token: token);
  SessionAction.undoWall() : this._timeline(SessionActionKind.undoWall);
  SessionAction._timeline(this.kind,
      {this.seed, Map<String, SessionValue> target = const {}, this.token})
      : target = Map.unmodifiable(target),
        commands = const [],
        events = const [],
        animate = false,
        viewport = null;
  final SessionActionKind kind;
  final List<SessionCommand> commands;
  final List<SessionEvent> events;
  final bool animate;
  final StateViewport? viewport;
  final int? seed;
  final Map<String, SessionValue> target;
  final SessionToken? token;
}

abstract interface class SessionOwnedHandle {
  void close();
}

abstract interface class SessionToken implements SessionOwnedHandle {}

class SessionReply {
  SessionReply(this.checkpoint,
      {this.paramToken,
      this.morphToken,
      this.physicalGeneration,
      List<StateInteraction> interactions = const [],
      List<StateKeyDisposition> keys = const []})
      : interactions = List.unmodifiable(interactions),
        keys = List.unmodifiable(keys);
  final SessionCheckpoint checkpoint;
  final SessionToken? paramToken;
  final SessionToken? morphToken;
  final BigInt? physicalGeneration;
  final List<StateInteraction> interactions;
  final List<StateKeyDisposition> keys;
}

class SessionWork {
  const SessionWork.trajectory()
      : command = null,
        maxTrialDivisions = 0;
  const SessionWork.wall(SessionCommand this.command,
      {this.maxTrialDivisions = 10000});
  final SessionCommand? command;
  final int maxTrialDivisions;
}

class SessionWorkRead {
  const SessionWorkRead(this.phase,
      {this.reply, this.error, this.wallStatus, this.stepsCompleted});
  final StateWorkPhase phase;
  final SessionReply? reply;
  final String? error;
  final StateNumberWallStatus? wallStatus;
  final int? stepsCompleted;
  bool get verifiedPrime =>
      phase == StateWorkPhase.finished &&
      wallStatus == StateNumberWallStatus.verifiedPrime &&
      error == null;
}

abstract interface class SessionTicket implements SessionOwnedHandle {
  Future<SessionWorkRead> read();

  /// Cancel and release this owned ticket, not the borrowed service.
  @override
  void close();
}

abstract interface class RustStateSessionBackend {
  Future<SessionReply> read();
  Future<SessionReply> execute(
      SessionAction action, BigInt sessionId, BigInt revision);
  Future<SessionTicket> schedule(
      SessionWork work, BigInt sessionId, BigInt revision,
      {SessionTicket? replace});
  Future<void> close();
}
