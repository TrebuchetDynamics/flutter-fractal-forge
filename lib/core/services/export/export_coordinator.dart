import 'dart:async';
import 'dart:io';

enum ExportKind { image, batch, video, looper }

final class ExportBusyException implements Exception {
  final ExportKind activeKind;

  const ExportBusyException(this.activeKind);

  @override
  String toString() => 'Another export is already running: ${activeKind.name}';
}

final class ExportCancelledException implements Exception {
  const ExportCancelledException();

  @override
  String toString() => 'Export cancelled';
}

final class ExportCancellationToken {
  final Completer<void> _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;

  bool cancel() {
    if (isCancelled) return false;
    _cancelled.complete();
    return true;
  }

  void throwIfCancelled() {
    if (isCancelled) throw const ExportCancelledException();
  }

  Future<File> retainSavedFileUnlessCancelled(File file) async {
    if (!isCancelled) return file;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Cancellation remains authoritative even when external storage refuses
      // cleanup; callers still suppress publication and success feedback.
    }
    throw const ExportCancelledException();
  }
}

typedef ExportOperationBody<T> = Future<T> Function(
  ExportCancellationToken token,
);

/// Serializes heavyweight export jobs across image, batch, video and looper
/// entry points and owns the cancellation token for the active job.
final class ExportCoordinator {
  static final ExportCoordinator shared = ExportCoordinator();

  ExportKind? _activeKind;
  ExportCancellationToken? _activeToken;
  Object? _activeIdentity;
  final Object _zoneTokenKey = Object();

  ExportKind? get activeKind => _activeKind;
  bool get isBusy => _activeKind != null;

  Future<T> run<T>(ExportKind kind, ExportOperationBody<T> body) async {
    final activeKind = _activeKind;
    if (activeKind != null) {
      final activeToken = _activeToken;
      if (activeToken != null &&
          activeKind == kind &&
          identical(Zone.current[_zoneTokenKey], activeToken)) {
        return body(activeToken);
      }
      throw ExportBusyException(activeKind);
    }

    final identity = Object();
    final token = ExportCancellationToken();
    _activeIdentity = identity;
    _activeKind = kind;
    _activeToken = token;

    try {
      token.throwIfCancelled();
      return await runZoned(
        () => body(token),
        zoneValues: {_zoneTokenKey: token},
      );
    } finally {
      if (identical(_activeIdentity, identity)) {
        _activeIdentity = null;
        _activeKind = null;
        _activeToken = null;
      }
    }
  }

  bool cancelActive() => _activeToken?.cancel() ?? false;
}
