import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';

const langtonAntRules = [
  'RL',
  'RLR',
  'LLRR',
  'RLLR',
  'LRRRRRLLR',
  'LLRRRLRLRLLR',
  'RRLLLRLLLRRR',
];
const langtonAntDefaultSteps = 11000;
const langtonAntMaxSteps = 1000000;

String? normalizeLangtonAntRule(Object? input) {
  if (input is! String ||
      input.length < 2 ||
      input.length > 20 ||
      input.codeUnits.any((c) => c != 76 && c != 82 && c != 108 && c != 114)) {
    return null;
  }
  return input.toUpperCase();
}

/// An immutable snapshot. Zero-colour cells are implicit, including revisited
/// cells that have cycled back to zero. Bounds include the entire walk.
class LangtonAntFrame {
  LangtonAntFrame._(
      this.rule,
      this.requestedSteps,
      this.completedSteps,
      this.x,
      this.y,
      this.minX,
      this.maxX,
      this.minY,
      this.maxY,
      this._heading,
      this._bound,
      this.stoppedAtBoundary,
      Map<int, int> cells)
      : cells = UnmodifiableMapView(cells);

  static const _limit = 32768;
  static const _width = 2 * _limit + 1;

  final String rule;
  final int requestedSteps, completedSteps;
  final int x, y, minX, maxX, minY, maxY;
  final Map<int, int> cells;

  final int _heading, _bound;
  final bool stoppedAtBoundary;

  // Arithmetic packing stays exact on both Dart VM and JS (33 bits).
  static int _key(int x, int y) => (y + _limit) * _width + x + _limit;
  static int cellX(int key) => key % _width - _limit;
  static int cellY(int key) => key ~/ _width - _limit;

  int colorAt(int x, int y) =>
      x.abs() > _limit || y.abs() > _limit ? 0 : cells[_key(x, y)] ?? 0;

  static LangtonAntFrame simulate(String rule, int steps,
      {int bound = _limit}) {
    final walk = LangtonAntWalk._(rule, bound)..advanceTo(steps);
    return walk._frame(steps, walk._cells);
  }

  static Future<LangtonAntFrame> prepare(String rule, int steps) async {
    if (!kIsWeb) {
      return compute(_simulateRequest, (rule, steps),
          debugLabel: 'Langton ant');
    }
    // Flutter web has no Dart isolates. Yield between batches there; native
    // platforms run the entire walk off the UI isolate.
    final walk = LangtonAntWalk._(rule, _limit);
    while (walk.advanceTo(steps, batch: 8192)) {
      await Future<void>.delayed(Duration.zero);
    }
    return walk._frame(steps, walk._cells);
  }
}

LangtonAntFrame _simulateRequest((String, int) request) =>
    LangtonAntFrame.simulate(request.$1, request.$2);

/// A forward-only walk resumed from an exact frame, including its heading.
class LangtonAntWalk {
  LangtonAntWalk._(String rule, this._bound)
      : rule = normalizeLangtonAntRule(rule) ??
            (throw ArgumentError.value(rule, 'rule')) {
    RangeError.checkValueInInterval(_bound, 0, LangtonAntFrame._limit, 'bound');
  }

  static Future<LangtonAntWalk> resume(LangtonAntFrame frame) async {
    return LangtonAntWalk._(frame.rule, frame._bound)
      .._cells = await _copyCells(frame.cells)
      .._step = frame.completedSteps
      .._x = frame.x
      .._y = frame.y
      .._heading = frame._heading
      .._minX = frame.minX
      .._maxX = frame.maxX
      .._minY = frame.minY
      .._maxY = frame.maxY
      .._stoppedAtBoundary = frame.stoppedAtBoundary;
  }

  final String rule;
  final int _bound;
  var _cells = <int, int>{};
  int _x = 0, _y = 0, _heading = 0, _step = 0;
  int _minX = 0, _maxX = 0, _minY = 0, _maxY = 0;
  bool _stoppedAtBoundary = false;

  int get completedSteps => _step;

  /// Returns whether more batches are needed to reach the requested step.
  bool advanceTo(int steps, {int batch = langtonAntMaxSteps}) {
    RangeError.checkValueInInterval(steps, _step, langtonAntMaxSteps, 'steps');
    if (_stoppedAtBoundary) return false;
    final end = min(_step + batch, steps);
    for (; _step < end; _step++) {
      final key = LangtonAntFrame._key(_x, _y);
      final color = _cells[key] ?? 0;
      final heading = (_heading + (rule.codeUnitAt(color) == 82 ? 1 : 3)) % 4;
      final x = _x + const [0, 1, 0, -1][heading];
      final y = _y + const [1, 0, -1, 0][heading];
      if (x.abs() > _bound || y.abs() > _bound) {
        _stoppedAtBoundary = true;
        return false;
      }
      final next = color + 1;
      if (next == rule.length) {
        _cells.remove(key);
      } else {
        _cells[key] = next;
      }
      _heading = heading;
      _x = x;
      _y = y;
      _minX = min(_minX, x);
      _maxX = max(_maxX, x);
      _minY = min(_minY, y);
      _maxY = max(_maxY, y);
    }
    return _step < steps;
  }

  // Do not advance the walk again until the snapshot is ready. Copying the
  // grid in slices keeps large frames from monopolizing the UI isolate.
  Future<LangtonAntFrame> snapshot() async =>
      _frame(_step, await _copyCells(_cells));

  static Future<Map<int, int>> _copyCells(Map<int, int> cells) async {
    if (cells.length <= 8192) return Map.of(cells);
    final copy = <int, int>{};
    var count = 0;
    for (final entry in cells.entries) {
      copy[entry.key] = entry.value;
      if (++count % 8192 == 0) await Future<void>.delayed(Duration.zero);
    }
    return copy;
  }

  LangtonAntFrame _frame(int requestedSteps, Map<int, int> cells) =>
      LangtonAntFrame._(rule, requestedSteps, _step, _x, _y, _minX, _maxX,
          _minY, _maxY, _heading, _bound, _stoppedAtBoundary, cells);
}
