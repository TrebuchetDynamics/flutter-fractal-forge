import 'dart:math' as math;

/// Finite translated-triangle Perron tree, not a measure-zero limiting set.
class PerronTree {
  static final halfBase = 1 / math.sqrt(3);
  final int depth;
  final double overlap;
  late final List<double> offsets = List.unmodifiable(_offsets());

  PerronTree({required this.depth, required this.overlap}) {
    if (depth < 0 ||
        depth > 5 ||
        !overlap.isFinite ||
        overlap < .5 ||
        overlap > 1) {
      throw ArgumentError(
          'Perron depth must be 0..5 and overlap finite in .5..1');
    }
  }

  int get leafCount => 1 << depth;
  double get centerX => halfBase * (1 - math.pow(overlap, depth));
  double get centerY => 1 - 2 * math.pow(overlap, depth) / 3;

  List<double> _offsets() {
    final result = List<double>.filled(leafCount, 0);
    final width = 2 * halfBase / leafCount;
    for (var stage = 0; stage < depth; stage++) {
      final group = 1 << stage;
      final heartHeight = math.pow(overlap, stage);
      // Align adjacent hearts, then overlap them without deforming their leaves.
      final shift = -group * width * (1 + heartHeight * (1 - 2 * overlap));
      for (var leaf = 0; leaf < leafCount; leaf++) {
        if ((leaf & group) != 0) result[leaf] += shift;
      }
    }
    return result;
  }
}
