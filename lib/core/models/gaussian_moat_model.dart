import 'package:flutter/foundation.dart';

typedef GaussianInteger = ({int a, int b});

/// Opt-in diagnostics at budget boundaries and the final (non-yielded) tail.
/// Elapsed wall time includes scheduling/preemption, not time awaiting a yield.
/// The 8ms budget is cooperative, not a hard upper bound on observed duration.
typedef GaussianMoatChunk = ({
  int probes,
  int elapsedMicroseconds,
  bool yielded,
});
typedef GaussianMoatMapJob = Future<GaussianPrimeMap?> Function(int bound,
    {bool Function()? isCancelled});

/// Serializes bounded map work and retains only the latest queued input.
class GaussianMoatMapJobQueue {
  GaussianMoatMapJobQueue(this._generate, this._publish,
      {void Function(Object error)? onError})
      : _onError = onError;

  final GaussianMoatMapJob _generate;
  final void Function(int bound, GaussianPrimeMap map) _publish;
  final void Function(Object error)? _onError;
  int _generation = 0;
  int? _pending;
  bool _running = false;
  bool _disposed = false;
  Future<void> _drainTask = Future<void>.value();

  void submit(int bound) {
    if (_disposed) return;
    _generation++;
    _pending = bound;
    if (!_running) _drainTask = _drain();
  }

  void cancel() {
    _generation++;
    _pending = null;
  }

  Future<void> get idle => _drainTask;

  Future<void> _drain() async {
    _running = true;
    while (!_disposed && _pending != null) {
      final bound = _pending!;
      final generation = _generation;
      _pending = null;
      try {
        final map = await _generate(bound,
            isCancelled: () => _disposed || generation != _generation);
        if (!_disposed && generation == _generation && map != null) {
          _publish(bound, map);
        }
      } catch (error) {
        if (!_disposed && generation == _generation) _onError?.call(error);
      }
    }
    _running = false;
  }

  void dispose() {
    _disposed = true;
    cancel();
  }
}

/// Bounded integer-squared connectivity radii shown by the growth controls.
class GaussianMoatGrowth {
  static const radii = [1, 2, 4, 8, 16];

  static int? next(int current) {
    for (final radius in radii) {
      if (radius > current) return radius;
    }
    return null;
  }
}

/// Exact membership only within a finite square; outside is uncomputed.
@immutable
class GaussianPrimeMap {
  static const defaultBound = 32;
  static const maxBound = 128;
  final int bound;
  final List<GaussianInteger> points;
  final Uint8List _membership;

  GaussianPrimeMap._(this.bound, List<GaussianInteger> points, this._membership)
      : points = List.unmodifiable(points);

  static int validateBound(num value) {
    if (!value.isFinite ||
        value < 1 ||
        value > maxBound ||
        value != value.truncate()) {
      throw ArgumentError.value(
          value, 'bound', 'Expected an integer in 1..128');
    }
    return value.toInt();
  }

  bool contains(GaussianInteger p) =>
      p.a >= -bound && p.a <= bound && p.b >= -bound && p.b <= bound;

  bool isPrime(GaussianInteger p) =>
      contains(p) &&
      _membership[(p.a + bound) * (2 * bound + 1) + p.b + bound] == 1;

  /// Complete connected component inside this finite map, using inclusive
  /// squared Euclidean distance. This is a bounded component, not a proof.
  Set<GaussianInteger> component(
    GaussianInteger start, {
    required int maxSquaredStep,
  }) {
    if (maxSquaredStep < 1 || maxSquaredStep > 16) {
      throw ArgumentError.value(maxSquaredStep, 'maxSquaredStep');
    }
    if (!isPrime(start)) return const {};
    final found = <GaussianInteger>{start};
    final queue = <GaussianInteger>[start];
    for (var head = 0; head < queue.length; head++) {
      final current = queue[head];
      for (var da = -4; da <= 4; da++) {
        for (var db = -4; db <= 4; db++) {
          final distance = da * da + db * db;
          if (distance == 0 || distance > maxSquaredStep) continue;
          final next = (a: current.a + da, b: current.b + db);
          if (isPrime(next) && found.add(next)) queue.add(next);
        }
      }
    }
    return Set.unmodifiable(found);
  }

  bool isAdjacent(GaussianInteger from, GaussianInteger to, int limit) {
    if (limit < 1 || limit > 16 || !isPrime(from) || !isPrime(to)) {
      return false;
    }
    final da = from.a - to.a;
    final db = from.b - to.b;
    return (da != 0 || db != 0) && da * da + db * db <= limit;
  }

  /// Returns null on cancellation, never publishes a partially generated map.
  static Future<GaussianPrimeMap?> generate(
    num value, {
    bool Function()? isCancelled,
    Future<void> Function()? yieldChunk,
    void Function(GaussianMoatChunk chunk)? onChunk,
  }) async {
    final bound = validateBound(value);
    if (isCancelled?.call() ?? false) return null;
    final limit = 2 * bound * bound;
    final sieve = Uint8List(limit + 1)..fillRange(2, limit + 1, 1);
    final membership = Uint8List((2 * bound + 1) * (2 * bound + 1));
    final points = <GaussianInteger>[];
    final clock = Stopwatch()..start();
    var probes = 0;
    bool chunkDue() => ++probes >= 1024 || clock.elapsedMicroseconds >= 8000;
    Future<bool> pause() async {
      onChunk?.call((
        probes: probes,
        elapsedMicroseconds: clock.elapsedMicroseconds,
        yielded: true,
      ));
      if (isCancelled?.call() ?? false) return true;
      await (yieldChunk?.call() ?? Future<void>.delayed(Duration.zero));
      probes = 0;
      clock.reset();
      return isCancelled?.call() ?? false;
    }

    for (var p = 2; p * p <= limit; p++) {
      if (sieve[p] != 0) {
        for (var n = p * p; n <= limit; n += p) {
          sieve[n] = 0;
          if (chunkDue() && await pause()) return null;
        }
      }
      if (chunkDue() && await pause()) return null;
    }
    for (var a = -bound; a <= bound; a++) {
      for (var b = -bound; b <= bound; b++) {
        final axis = a == 0 ? b.abs() : a.abs();
        final prime = a != 0 && b != 0
            ? sieve[a * a + b * b] == 1
            : axis % 4 == 3 && sieve[axis] == 1;
        if (prime) {
          final point = (a: a, b: b);
          points.add(point);
          membership[(a + bound) * (2 * bound + 1) + b + bound] = 1;
        }
        if (chunkDue() && await pause()) return null;
      }
    }
    if (isCancelled?.call() ?? false) return null;
    onChunk?.call((
      probes: probes,
      elapsedMicroseconds: clock.elapsedMicroseconds,
      yielded: false,
    ));
    return GaussianPrimeMap._(bound, points, membership);
  }
}
