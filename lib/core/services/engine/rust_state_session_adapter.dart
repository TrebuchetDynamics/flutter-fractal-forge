import 'package:flutter/foundation.dart';
import 'rust_state_session_backend.dart';
export 'rust_state_session_backend.dart';

import 'rust_state_session_backend_stub.dart'
    if (dart.library.io) 'rust_state_session_backend_native.dart' as platform;

enum SessionAdmission { accepted, busy, closed, rejected }

class SessionResult {
  const SessionResult(this.admission, {this.reply, this.error, this.work});
  final SessionAdmission admission;
  final SessionReply? reply;
  final Object? error;
  final SessionWorkRead? work;
}

/// Inert diagnostic owner. Busy means the caller still owns ALL unaccepted input.
class RustStateSessionAdapter {
  RustStateSessionAdapter._(this._backend, this._checkpoint);
  final RustStateSessionBackend _backend;
  SessionCheckpoint? _checkpoint;
  SessionCheckpoint? get checkpoint => _checkpoint;
  SessionToken? _paramToken, _morphToken;
  SessionToken? get paramToken => _paramToken;
  SessionToken? get morphToken => _morphToken;
  SessionTicket? _ticket;
  bool _busy = false, _closed = false;
  int _workGeneration = 0;
  Future<void>? _closing;
  final _released = Expando<bool>();
  void _release(SessionOwnedHandle? handle) {
    if (handle == null || _released[handle] == true) return;
    _released[handle] = true;
    handle.close();
  }

  static Future<RustStateSessionAdapter?> create(
      {bool enabled = false,
      bool isWeb = kIsWeb,
      Future<RustStateSessionBackend> Function()? loader}) async {
    if (!enabled || isWeb || kIsWeb) return null;
    final backend = await (loader ?? platform.loadRustStateSession)();
    try {
      final initial = await backend.read();
      final adapter = RustStateSessionAdapter._(backend, initial.checkpoint);
      if (!adapter._publish(initial))
        throw StateError('Invalid initial session read');
      return adapter;
    } catch (_) {
      await backend.close();
      rethrow;
    }
  }

  bool _publish(SessionReply reply) {
    final next = reply.checkpoint;
    final previous = _checkpoint!;
    final frame = next.data['trajectoryFrame'];
    final staleFrame = frame is Map<String, Object?> &&
        (frame['sessionId'] != next.sessionId ||
            frame['settingsGeneration'] != next.trajectoryGeneration);
    if (_closed ||
        staleFrame ||
        next.sessionId != previous.sessionId ||
        next.revision < previous.revision ||
        next.trajectoryGeneration < previous.trajectoryGeneration) {
      _releaseReply(reply);
      return false;
    }
    _checkpoint = next.withHiddenOwners({
      ...next.hiddenOwners,
      if (_paramToken != null || reply.paramToken != null)
        'parameter timeline token',
      if (_ticket != null) 'scheduled service ticket',
    });
    if (reply.paramToken != null) {
      if (!identical(_paramToken, reply.paramToken)) _release(_paramToken);
      _paramToken = reply.paramToken;
    }
    if (!identical(_morphToken, reply.morphToken)) _release(_morphToken);
    _morphToken = reply.morphToken;
    return true;
  }

  void _releaseReply(SessionReply reply) {
    if (!identical(reply.paramToken, _paramToken)) _release(reply.paramToken);
    if (!identical(reply.morphToken, _morphToken)) _release(reply.morphToken);
  }

  Future<SessionResult> _admit(
      Future<SessionResult> Function() operation) async {
    if (_closed) return const SessionResult(SessionAdmission.closed);
    if (_busy) return const SessionResult(SessionAdmission.busy);
    _busy = true;
    try {
      return await operation();
    } catch (error) {
      return SessionResult(
          _closed ? SessionAdmission.closed : SessionAdmission.rejected,
          error: error);
    } finally {
      _busy = false;
    }
  }

  Future<SessionResult> apply(SessionAction action) => _admit(() async {
        final before = _checkpoint!;
        final reply =
            await _backend.execute(action, before.sessionId, before.revision);
        if (!_publish(reply))
          return SessionResult(
              _closed ? SessionAdmission.closed : SessionAdmission.rejected);
        if (action.kind == SessionActionKind.cancelParams) {
          _release(_paramToken);
          _paramToken = null;
        }
        return SessionResult(SessionAdmission.accepted, reply: reply);
      });

  Future<SessionResult> refresh() => _admit(() async {
        final reply = await _backend.read();
        if (!_publish(reply))
          return SessionResult(
              _closed ? SessionAdmission.closed : SessionAdmission.rejected);
        return SessionResult(SessionAdmission.accepted, reply: reply);
      });

  Future<SessionResult> schedule(SessionWork work) => _admit(() async {
        final generation = ++_workGeneration;
        final previous = _ticket;
        final state = _checkpoint!;
        final next = await _backend
            .schedule(work, state.sessionId, state.revision, replace: previous);
        if (_closed || generation != _workGeneration) {
          _release(next);
          return SessionResult(
              _closed ? SessionAdmission.closed : SessionAdmission.rejected);
        }
        _release(previous);
        _ticket = next;
        _checkpoint = _checkpoint!.withHiddenOwners({
          ..._checkpoint!.hiddenOwners,
          'scheduled service ticket',
        });
        return const SessionResult(SessionAdmission.accepted);
      });

  Future<SessionResult> poll() => _admit(() async {
        final ticket = _ticket;
        if (ticket == null)
          return const SessionResult(SessionAdmission.rejected);
        final generation = _workGeneration;
        final value = await ticket.read();
        if (_closed ||
            generation != _workGeneration ||
            !identical(ticket, _ticket)) {
          if (value.reply != null) _releaseReply(value.reply!);
          return SessionResult(
              _closed ? SessionAdmission.closed : SessionAdmission.rejected);
        }
        if (value.error != null || value.phase == StateWorkPhase.failed) {
          if (value.reply != null) _releaseReply(value.reply!);
          return SessionResult(SessionAdmission.rejected, error: value.error);
        }
        if (value.reply != null && !_publish(value.reply!)) {
          return const SessionResult(SessionAdmission.rejected);
        }
        return SessionResult(SessionAdmission.accepted, work: value);
      });

  /// Can invalidate an awaited poll without accepting another mutation.
  void cancelWork() {
    ++_workGeneration;
    _release(_ticket);
    _ticket = null;
  }

  Future<void> dispose() {
    if (_closing != null) return _closing!;
    _closed = true;
    cancelWork();
    _release(_paramToken);
    _paramToken = null;
    _release(_morphToken);
    _morphToken = null;
    return _closing = _backend.close();
  }
}
