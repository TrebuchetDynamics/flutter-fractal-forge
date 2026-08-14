import 'dart:typed_data';

import 'package:flutter_fractals/features/fourier/services/fourier_analysis_backend.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_analysis_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persistent worker analyzes multiple frames in one isolate', () async {
    final backend = await IsolateFourierAnalysisBackend.spawn();
    addTearDown(backend.close);

    final first = await backend.analyze(_checkerboardRequest(1));
    final second = await backend.analyze(_checkerboardRequest(2));

    expect(backend.spawnedIsolateCount, 1);
    for (final result in [first, second]) {
      expect(result.blank, isFalse);
      expect(result.width, 8);
      expect(result.height, 8);
      expect(result.spectrumRgba, hasLength(8 * 8 * 4));
      expect(result.features.highPowerRatio, closeTo(1, 1e-10));
      expect(result.elapsedMicroseconds, greaterThan(0));
    }
  });

  test('worker marks a uniform capture blank without fabricating detail',
      () async {
    final backend = await IsolateFourierAnalysisBackend.spawn();
    addTearDown(backend.close);

    final result = await backend.analyze(
      FourierWorkerRequest(
        generation: 1,
        rgba: Uint8List.fromList(
          List<int>.generate(8 * 8 * 4, (index) => index % 4 == 3 ? 255 : 80),
        ),
        width: 8,
        height: 8,
        maxDimension: 128,
        removeDc: true,
        applyHann: true,
      ),
    );

    expect(result.blank, isTrue);
    expect(result.spectrumRgba.every((value) => value == 0), isFalse);
  });

  test('worker completes a realistic viewport shape within its budget',
      () async {
    final backend = await IsolateFourierAnalysisBackend.spawn();
    addTearDown(backend.close);
    final rgba = Uint8List(211 * 175 * 4);
    for (var offset = 0; offset < rgba.length; offset += 4) {
      final value = ((offset ~/ 4) * 37) & 255;
      rgba[offset] = value;
      rgba[offset + 1] = 255 - value;
      rgba[offset + 2] = (value * 3) & 255;
      rgba[offset + 3] = 255;
    }

    final result = await backend
        .analyze(
          FourierWorkerRequest(
            generation: 1,
            rgba: rgba,
            width: 211,
            height: 175,
            maxDimension: 128,
            removeDc: true,
            applyHann: true,
          ),
        )
        .timeout(const Duration(seconds: 3));

    expect(result.width, 128);
    expect(result.height, 106);
    expect(result.elapsedMicroseconds, lessThan(500000));
  });
}

FourierWorkerRequest _checkerboardRequest(int generation) {
  final rgba = Uint8List(8 * 8 * 4);
  for (var y = 0; y < 8; y++) {
    for (var x = 0; x < 8; x++) {
      final value = (x + y).isEven ? 0 : 255;
      final offset = (y * 8 + x) * 4;
      rgba[offset] = value;
      rgba[offset + 1] = value;
      rgba[offset + 2] = value;
      rgba[offset + 3] = 255;
    }
  }
  return FourierWorkerRequest(
    generation: generation,
    rgba: rgba,
    width: 8,
    height: 8,
    maxDimension: 128,
    removeDc: true,
    applyHann: false,
  );
}
