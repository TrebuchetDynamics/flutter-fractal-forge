import 'dart:async';

/// Bounds how many catalog thumbnails keep a live GPU renderer at once.
///
/// Without a gate, every visible tile mounted its own FractalRenderer almost
/// simultaneously (the old pipeline staggered them with blind timers, so a
/// full screen still ended up with ~20 concurrent shader compiles within
/// ~1.4s). The gate keeps exactly [maxConcurrent] renders in flight and hands
/// each freed slot straight to the next waiter, so tiles render as soon as a
/// slot frees - no arbitrary delays, no compile herd.
class CatalogThumbnailRenderGate {
  CatalogThumbnailRenderGate._();

  /// Configurable ceiling for concurrent live thumbnail renders.
  static const int _configuredMaxConcurrent = int.fromEnvironment(
    'RUNTIME_CATALOG_THUMBNAILS_MAX_CONCURRENT',
    defaultValue: 4,
  );
  static const int maxConcurrent =
      _configuredMaxConcurrent < 1 ? 1 : _configuredMaxConcurrent;

  static int _active = 0;
  static final List<Completer<void>> _waiters = <Completer<void>>[];

  /// Current in-flight renders (exposed for tests and diagnostics).
  static int get activeForTesting => _active;

  /// Number of renderers currently queued for a slot.
  static int get queuedForTesting => _waiters.length;

  /// Resolves as soon as the caller holds one of the [maxConcurrent] slots.
  ///
  /// The future may resolve after the caller is gone; a resolved-but-unwanted
  /// slot must still be [release]d (or handed over) by the caller, so acquire
  /// sites must re-check liveness in their completion callback.
  static Future<void> acquire() {
    if (_active < maxConcurrent) {
      _active++;
      return Future<void>.value();
    }
    final waiter = Completer<void>();
    _waiters.add(waiter);
    return waiter.future;
  }

  /// Frees one slot. When renderers are queued, the slot is handed over
  /// directly to the next waiter instead of bouncing through the counter.
  static void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
      return;
    }
    if (_active > 0) _active--;
  }

  /// Completes all waiters and clears the counter. Test isolation only.
  static void resetForTesting() {
    _active = 0;
    final waiters = List<Completer<void>>.of(_waiters);
    _waiters.clear();
    for (final waiter in waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
  }
}
