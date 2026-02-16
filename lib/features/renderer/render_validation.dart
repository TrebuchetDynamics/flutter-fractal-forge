import 'dart:typed_data';

class RenderFrameStats {
  final int centerR;
  final int centerG;
  final int centerB;
  final double nonBlackRatio;
  final bool centerNonBlack;
  final bool histogramSane;

  const RenderFrameStats({
    required this.centerR,
    required this.centerG,
    required this.centerB,
    required this.nonBlackRatio,
    required this.centerNonBlack,
    required this.histogramSane,
  });

  String summary(String backend) {
    return '[renderer] render_frame_stats backend=$backend center=$centerR,$centerG,$centerB non_black_ratio=${nonBlackRatio.toStringAsFixed(4)} histogram_sane=$histogramSane';
  }
}

RenderFrameStats validateRenderFrame({
  required Uint8List frame,
  required int width,
  required int height,
}) {
  int idx(int x, int y) => (y * width + x) * 4;

  final cx = (width / 2).floor();
  final cy = (height / 2).floor();
  final cIndex = idx(cx, cy);
  final centerR = frame[cIndex];
  final centerG = frame[cIndex + 1];
  final centerB = frame[cIndex + 2];

  final centerNonBlack = centerR > 8 || centerG > 8 || centerB > 8;

  int nonBlack = 0;
  final total = width * height;

  for (int i = 0; i + 3 < frame.length; i += 4) {
    if (frame[i] > 8 || frame[i + 1] > 8 || frame[i + 2] > 8) {
      nonBlack++;
    }
  }

  final nonBlackRatio = total == 0 ? 0.0 : nonBlack / total;
  final histogramSane = nonBlackRatio > 0.01;

  return RenderFrameStats(
    centerR: centerR,
    centerG: centerG,
    centerB: centerB,
    nonBlackRatio: nonBlackRatio,
    centerNonBlack: centerNonBlack,
    histogramSane: histogramSane,
  );
}

class RenderCheckResult {
  final int centerR;
  final int centerG;
  final int centerB;
  final double nonBlackRatio;
  final bool centerNonBlack;
  final bool histogramSane;
  final bool frameProgressed;
  final bool iterationDeltaVisible;

  const RenderCheckResult({
    required this.centerR,
    required this.centerG,
    required this.centerB,
    required this.nonBlackRatio,
    required this.centerNonBlack,
    required this.histogramSane,
    required this.frameProgressed,
    required this.iterationDeltaVisible,
  });

  bool get pass =>
      centerNonBlack &&
      histogramSane &&
      frameProgressed &&
      iterationDeltaVisible;

  String summary(String backend) {
    return '[renderer] render_check backend=$backend pass=$pass center=$centerR,$centerG,$centerB non_black_ratio=${nonBlackRatio.toStringAsFixed(4)} frame_progressed=$frameProgressed iter_delta=$iterationDeltaVisible';
  }
}

RenderCheckResult validateRenderPair({
  required Uint8List frameA,
  required Uint8List frameB,
  required int width,
  required int height,
}) {
  int idx(int x, int y) => (y * width + x) * 4;

  final cx = (width / 2).floor();
  final cy = (height / 2).floor();
  final cIndex = idx(cx, cy);
  final centerR = frameB[cIndex];
  final centerG = frameB[cIndex + 1];
  final centerB = frameB[cIndex + 2];

  final centerNonBlack = centerR > 8 || centerG > 8 || centerB > 8;

  int nonBlack = 0;
  int total = width * height;
  int different = 0;

  for (int i = 0; i + 3 < frameB.length; i += 4) {
    if (frameB[i] > 8 || frameB[i + 1] > 8 || frameB[i + 2] > 8) {
      nonBlack++;
    }

    final dr = (frameB[i] - frameA[i]).abs();
    final dg = (frameB[i + 1] - frameA[i + 1]).abs();
    final db = (frameB[i + 2] - frameA[i + 2]).abs();
    if (dr + dg + db > 12) different++;
  }

  final nonBlackRatio = total == 0 ? 0.0 : nonBlack / total;
  final histogramSane = nonBlackRatio > 0.01;
  final progressionRatio = total == 0 ? 0.0 : different / total;
  final frameProgressed = progressionRatio > 0.002;
  final iterationDeltaVisible = progressionRatio > 0.01;

  return RenderCheckResult(
    centerR: centerR,
    centerG: centerG,
    centerB: centerB,
    nonBlackRatio: nonBlackRatio,
    centerNonBlack: centerNonBlack,
    histogramSane: histogramSane,
    frameProgressed: frameProgressed,
    iterationDeltaVisible: iterationDeltaVisible,
  );
}
