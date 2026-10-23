import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/perron_tree_model.dart';

// Independent vertical sweep: integrate the union of affine interval endpoints
// between every endpoint crossing, rather than reusing the heart recurrence.
double area(PerronTree tree) {
  final lines = <(double, double)>[];
  final h = PerronTree.halfBase;
  for (var i = 0; i < tree.leafCount; i++) {
    lines.add((tree.offsets[i], -h + 2 * h * i / tree.leafCount));
    lines.add((tree.offsets[i], -h + 2 * h * (i + 1) / tree.leafCount));
  }
  final breaks = <double>{0, 1};
  for (final a in lines) {
    for (final b in lines) {
      if ((a.$2 - b.$2).abs() < 1e-14) continue;
      final y = (b.$1 - a.$1) / (a.$2 - b.$2);
      if (y > 0 && y < 1) breaks.add(y);
    }
  }
  double width(double y) {
    final intervals = <(double, double)>[];
    for (var i = 0; i < lines.length; i += 2) {
      intervals.add((
        lines[i].$1 + lines[i].$2 * y,
        lines[i + 1].$1 + lines[i + 1].$2 * y
      ));
    }
    intervals.sort((a, b) => a.$1.compareTo(b.$1));
    var start = intervals.first.$1, end = intervals.first.$2, total = 0.0;
    for (final pair in intervals.skip(1)) {
      if (pair.$1 > end) {
        total += end - start;
        start = pair.$1;
      }
      end = math.max(end, pair.$2);
    }
    return total + end - start;
  }

  final ys = breaks.toList()..sort();
  var sum = 0.0;
  for (var i = 1; i < ys.length; i++) {
    sum += (ys[i] - ys[i - 1]) * (width(ys[i]) + width(ys[i - 1])) / 2;
  }
  return sum;
}

void main() {
  test('two merging stages translate intact leaves by the heart construction',
      () {
    final tree = PerronTree(depth: 2, overlap: .75), h = PerronTree.halfBase;
    expect(tree.offsets, orderedEquals([0.0, -h / 4, -5 * h / 8, -7 * h / 8]));
    expect(() => tree.offsets[0] = 2, throwsUnsupportedError);
  });
  test('independent interval-union area obeys finite Perron bounds', () {
    for (final alpha in [.5, .75, .8, .99, 1.0]) {
      for (var depth = 0; depth <= 5; depth++) {
        final tree = PerronTree(depth: depth, overlap: alpha);
        final ratio = area(tree) / PerronTree.halfBase;
        final bound =
            math.pow(alpha, 2 * depth) + 2 * (1 - alpha) / (1 + alpha);
        expect(ratio, greaterThan(0));
        expect(ratio, lessThanOrEqualTo(1 + 1e-9));
        expect(ratio, lessThanOrEqualTo(bound + 1e-9),
            reason: 'd=$depth, alpha=$alpha');
        if (depth == 1)
          expect(ratio,
              closeTo(alpha * alpha + 2 * (1 - alpha) * (1 - alpha), 1e-9));
      }
    }
  });
  test('three rotated fans contain a unit segment in every sampled direction',
      () {
    for (final depth in [0, 3, 5]) {
      final tree = PerronTree(depth: depth, overlap: .8);
      for (var degrees = 0; degrees < 180; degrees++) {
        final theta = degrees * math.pi / 180;
        var found = false;
        for (var fan = 0; fan < 3; fan++) {
          final angle = theta - fan * 2 * math.pi / 3;
          var dx = math.cos(angle), dy = math.sin(angle);
          if (dy < 0) {
            dx = -dx;
            dy = -dy;
          }
          if (dy < 1e-12) continue;
          final slope = dx / dy, h = PerronTree.halfBase;
          if (slope < -h - 1e-10 || slope > h + 1e-10) continue;
          final leaf = ((slope + h) / (2 * h) * tree.leafCount)
              .floor()
              .clamp(0, tree.leafCount - 1);
          final left = -h + 2 * h * leaf / tree.leafCount,
              right = -h + 2 * h * (leaf + 1) / tree.leafCount;
          for (var step = 0; step <= 10; step++) {
            final y = dy * step / 10, x = dx * step / 10;
            expect(y, inInclusiveRange(0, 1));
            expect(x, greaterThanOrEqualTo(left * y - 1e-9));
            expect(x, lessThanOrEqualTo(right * y + 1e-9));
          }
          expect(math.sqrt(dx * dx + dy * dy), closeTo(1, 1e-12));
          found = true;
          break;
        }
        expect(found, isTrue, reason: 'Missing $degrees degrees');
      }
    }
  });
  test('invalid numerical input is rejected, not turned into geometry', () {
    for (final depth in [-1, 6]) {
      expect(() => PerronTree(depth: depth, overlap: .8), throwsArgumentError);
    }
    for (final a in [double.nan, double.infinity, .49, 1.01]) {
      expect(() => PerronTree(depth: 3, overlap: a), throwsArgumentError);
    }
  });
}
