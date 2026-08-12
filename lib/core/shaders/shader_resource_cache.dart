import 'dart:collection';

/// Why a shader cache was cleared.
enum ShaderCacheClearReason { memoryPressure, shutdown, manual }

/// Testable snapshot of shader cache health.
class ShaderCacheMetrics {
  const ShaderCacheMetrics({
    required this.size,
    required this.evictions,
    required this.lastClearReason,
  });

  final int size;
  final int evictions;
  final ShaderCacheClearReason? lastClearReason;
}

/// A bounded LRU pool for reusable shader-like resources.
///
/// Acquired resources are leased to a renderer and are not part of the idle LRU
/// until [release] is called. The supplied disposer owns native teardown.
class ShaderResourceCache<T extends Object> {
  ShaderResourceCache({
    required this.maximumSize,
    required void Function(T resource) disposeResource,
  })  : assert(maximumSize > 0),
        _disposeResource = disposeResource;

  final int maximumSize;
  final void Function(T resource) _disposeResource;
  final LinkedHashMap<String, T> _idle = LinkedHashMap<String, T>();
  final Map<T, String> _active = Map<T, String>.identity();
  final Set<T> _disposeOnRelease = Set<T>.identity();

  int _evictions = 0;
  ShaderCacheClearReason? _lastClearReason;

  ShaderCacheMetrics get metrics => ShaderCacheMetrics(
        size: _idle.length,
        evictions: _evictions,
        lastClearReason: _lastClearReason,
      );

  T acquire(String key, T Function() create) {
    final resource = _idle.remove(key) ?? create();
    _active[resource] = key;
    return resource;
  }

  void release(T resource) {
    final key = _active.remove(resource);
    if (key == null) return;
    if (_disposeOnRelease.remove(resource)) {
      _disposeResource(resource);
      return;
    }

    final replaced = _idle.remove(key);
    if (replaced != null && !identical(replaced, resource)) {
      _disposeResource(replaced);
    }
    _idle[key] = resource;

    while (_idle.length > maximumSize) {
      final oldestKey = _idle.keys.first;
      final oldest = _idle.remove(oldestKey)!;
      _disposeResource(oldest);
      _evictions++;
    }
  }

  /// Clears idle resources immediately and retires active leases on release.
  void clear(ShaderCacheClearReason reason) {
    for (final resource in _idle.values) {
      _disposeResource(resource);
    }
    _idle.clear();
    _disposeOnRelease.addAll(_active.keys);
    _lastClearReason = reason;
  }
}
