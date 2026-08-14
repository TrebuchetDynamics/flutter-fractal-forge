import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/features/fourier/models/fourier_spectrum_features.dart';

final class FourierWorkerRequest {
  FourierWorkerRequest({
    required this.generation,
    required Uint8List rgba,
    required this.width,
    required this.height,
    required this.maxDimension,
    required this.removeDc,
    required this.applyHann,
  }) : rgba = Uint8List.fromList(rgba);

  final int generation;
  final Uint8List rgba;
  final int width;
  final int height;
  final int maxDimension;
  final bool removeDc;
  final bool applyHann;
}

final class FourierWorkerResult {
  FourierWorkerResult({
    required this.generation,
    required Uint8List spectrumRgba,
    required this.width,
    required this.height,
    required this.features,
    required this.blank,
    required this.elapsedMicroseconds,
  }) : spectrumRgba = Uint8List.fromList(spectrumRgba);

  final int generation;
  final Uint8List spectrumRgba;
  final int width;
  final int height;
  final FourierSpectrumFeatures features;
  final bool blank;
  final int elapsedMicroseconds;
}

abstract interface class FourierAnalysisBackend {
  Future<FourierWorkerResult> analyze(FourierWorkerRequest request);
  Future<void> close();
}

/// Serializes capture analysis and coalesces motion bursts to the newest frame.
///
/// At most one request is executing. While it runs, repeated submissions replace
/// a single pending request. A completed result is published only when its
/// generation is still the newest requested generation.
class FourierAnalysisController extends ChangeNotifier {
  FourierAnalysisController({required FourierAnalysisBackend backend})
      : _backend = backend;

  final FourierAnalysisBackend _backend;
  FourierWorkerRequest? _pending;
  FourierWorkerResult? _result;
  FourierWorkerResult? _latestAttempt;
  bool _running = false;
  bool _disposed = false;
  bool _unavailable = false;
  Object? _error;
  int _latestGeneration = -1;

  FourierWorkerResult? get result => _result;
  FourierWorkerResult? get latestAttempt => _latestAttempt;
  bool get processing => _running || _pending != null;
  bool get unavailable => _unavailable;
  Object? get error => _error;

  void submit(FourierWorkerRequest request) {
    if (_disposed) return;
    if (request.generation <= _latestGeneration) return;
    _latestGeneration = request.generation;
    _unavailable = false;
    _error = null;
    if (_running) {
      _pending = request;
      notifyListeners();
      return;
    }
    _start(request);
  }

  void _start(FourierWorkerRequest request) {
    _running = true;
    notifyListeners();
    unawaited(_run(request));
  }

  Future<void> _run(FourierWorkerRequest request) async {
    try {
      final next = await _backend.analyze(request);
      if (_disposed) return;
      if (next.generation == _latestGeneration) {
        _latestAttempt = next;
        if (next.blank) {
          _unavailable = true;
        } else {
          _result = next;
          _unavailable = false;
        }
        _error = null;
      }
    } catch (error) {
      if (!_disposed && request.generation == _latestGeneration) {
        _error = error;
        _unavailable = true;
      }
    } finally {
      if (!_disposed) {
        final next = _pending;
        _pending = null;
        if (next == null) {
          _running = false;
          notifyListeners();
        } else {
          _running = false;
          _start(next);
        }
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _pending = null;
    unawaited(_backend.close());
    super.dispose();
  }
}
