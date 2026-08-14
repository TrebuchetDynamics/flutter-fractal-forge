import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_fractals/features/fourier/models/fourier_spectrum_features.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_analysis_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('latest-wins scheduling suppresses stale results', () async {
    final backend = _FakeBackend();
    final controller = FourierAnalysisController(backend: backend);
    addTearDown(controller.dispose);

    controller.submit(_request(1));
    controller.submit(_request(2));
    controller.submit(_request(3));
    expect(backend.requests.map((request) => request.generation), [1]);

    backend.completeNext(_result(1));
    await Future<void>.delayed(Duration.zero);
    expect(controller.result, isNull);
    expect(backend.requests.map((request) => request.generation), [1, 3]);

    backend.completeNext(_result(3));
    await Future<void>.delayed(Duration.zero);
    expect(controller.result?.generation, 3);
    expect(controller.processing, isFalse);
  });

  test('blank capture retains the last valid spectrum and reports unavailable',
      () async {
    final backend = _FakeBackend();
    final controller = FourierAnalysisController(backend: backend);
    addTearDown(controller.dispose);

    controller.submit(_request(1));
    backend.completeNext(_result(1));
    await Future<void>.delayed(Duration.zero);
    expect(controller.result?.generation, 1);

    controller.submit(_request(2));
    backend.completeNext(_result(2, blank: true));
    await Future<void>.delayed(Duration.zero);
    expect(controller.result?.generation, 1);
    expect(controller.unavailable, isTrue);
    expect(controller.error, isNull);
  });

  test('dispose stops publication and disposes the backend', () async {
    final backend = _FakeBackend();
    final controller = FourierAnalysisController(backend: backend);
    controller.submit(_request(1));

    controller.dispose();
    backend.completeNext(_result(1));
    await Future<void>.delayed(Duration.zero);

    expect(backend.disposed, isTrue);
  });
}

FourierWorkerRequest _request(int generation) => FourierWorkerRequest(
      generation: generation,
      rgba: Uint8List.fromList([0, 0, 0, 255]),
      width: 1,
      height: 1,
      maxDimension: 128,
      removeDc: true,
      applyHann: true,
    );

FourierWorkerResult _result(int generation, {bool blank = false}) =>
    FourierWorkerResult(
      generation: generation,
      spectrumRgba: Uint8List.fromList([20, 30, 80, 255]),
      width: 1,
      height: 1,
      features: FourierSpectrumFeatures(
        radialBandPower: const [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        lowPowerRatio: 1,
        midPowerRatio: 0,
        highPowerRatio: 0,
        centroid: 0,
        bandwidth: 0,
        rolloff85: 0,
        logPowerSlope: 0,
        radialPeakSalience: 0,
        entropy: 0,
        flatness: 0,
        dominantOrientation: 0,
        orientationStrength: 0,
        spectralFlux: 0,
        captureMean: 0.5,
        captureVariance: 0.1,
        alphaCoverage: 1,
        width: 1,
        height: 1,
        windowApplied: true,
        dcRemoved: true,
      ),
      blank: blank,
      elapsedMicroseconds: 10,
    );

class _FakeBackend implements FourierAnalysisBackend {
  final requests = <FourierWorkerRequest>[];
  final _pending = <Completer<FourierWorkerResult>>[];
  bool disposed = false;

  @override
  Future<FourierWorkerResult> analyze(FourierWorkerRequest request) {
    requests.add(request);
    final completer = Completer<FourierWorkerResult>();
    _pending.add(completer);
    return completer.future;
  }

  void completeNext(FourierWorkerResult result) {
    _pending.removeAt(0).complete(result);
  }

  @override
  Future<void> close() async => disposed = true;
}
