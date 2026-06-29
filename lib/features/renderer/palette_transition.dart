import 'dart:math' as math;

class PaletteTransition {
  static const duration = Duration(milliseconds: 250);

  double? _from;
  double? _to;
  DateTime? _startedAt;
  double? _lastValue;

  double valueFor({
    required Object? target,
    required DateTime now,
    required double min,
    required double max,
    required bool animate,
  }) {
    final targetValue = target is num ? target.toDouble() : min;
    if (!animate) return _reset(targetValue);

    if (_to == null) return _reset(targetValue);
    if (_to != targetValue) {
      _from = _lastValue ?? targetValue;
      _to = targetValue;
      _startedAt = now;
    }

    final from = _from ?? targetValue;
    final elapsed = now.difference(_startedAt ?? now);
    final t = elapsed.inMicroseconds / duration.inMicroseconds;
    if (t >= 1.0) return _reset(targetValue);

    final eased = 1.0 - math.pow(1.0 - t.clamp(0.0, 1.0), 3).toDouble();
    final to = from.round() == max.round() && targetValue == min
        ? max + 1.0
        : targetValue;
    return _lastValue = from + (to - from) * eased;
  }

  double _reset(double targetValue) {
    _from = targetValue;
    _to = targetValue;
    _startedAt = null;
    return _lastValue = targetValue;
  }
}
