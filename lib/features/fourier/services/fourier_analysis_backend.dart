import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_fractals/features/fourier/models/fourier_spectrum_features.dart';

import 'fourier_analysis_controller.dart';
import 'fourier_image_analyzer.dart';

/// A single persistent isolate used for every Fourier frame in a viewer session.
final class IsolateFourierAnalysisBackend implements FourierAnalysisBackend {
  IsolateFourierAnalysisBackend._(
    this._isolate,
    this._workerPort,
    this._receivePort,
  ) {
    _subscription = _receivePort.listen(_handleMessage);
  }

  static Future<IsolateFourierAnalysisBackend> spawn() async {
    final handshakePort = ReceivePort();
    final resultPort = ReceivePort();
    final isolate = await Isolate.spawn(
      _fourierWorkerMain,
      <SendPort>[handshakePort.sendPort, resultPort.sendPort],
    );
    final workerPort = await handshakePort.first as SendPort;
    handshakePort.close();
    return IsolateFourierAnalysisBackend._(isolate, workerPort, resultPort);
  }

  final Isolate _isolate;
  final SendPort _workerPort;
  final ReceivePort _receivePort;
  late final StreamSubscription<dynamic> _subscription;
  final Map<int, Completer<FourierWorkerResult>> _pending = {};
  int _nextRequestId = 0;
  bool _closed = false;

  int get spawnedIsolateCount => 1;

  @override
  Future<FourierWorkerResult> analyze(FourierWorkerRequest request) {
    if (_closed) return Future.error(StateError('Fourier worker is closed.'));
    final id = _nextRequestId++;
    final completer = Completer<FourierWorkerResult>();
    _pending[id] = completer;
    _workerPort.send(<Object?>[
      'analyze',
      id,
      request.generation,
      TransferableTypedData.fromList([request.rgba]),
      request.width,
      request.height,
      request.maxDimension,
      request.removeDc,
      request.applyHann,
    ]);
    return completer.future;
  }

  void _handleMessage(dynamic message) {
    if (message is! List<Object?> || message.length < 3) return;
    final id = message[1]! as int;
    final completer = _pending.remove(id);
    if (completer == null) return;
    if (message[0] == 'error') {
      completer.completeError(StateError(message[2]! as String));
      return;
    }
    final bytes = (message[3]! as TransferableTypedData).materialize();
    completer.complete(
      FourierWorkerResult(
        generation: message[2]! as int,
        spectrumRgba: bytes.asUint8List(),
        width: message[4]! as int,
        height: message[5]! as int,
        features: _decodeFeatures(message[6]! as List<Object?>),
        blank: message[7]! as bool,
        elapsedMicroseconds: message[8]! as int,
      ),
    );
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _workerPort.send(const <Object?>['close']);
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Fourier worker closed.'));
      }
    }
    _pending.clear();
    await _subscription.cancel();
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }
}

void _fourierWorkerMain(List<SendPort> ports) {
  final handshake = ports[0];
  final parent = ports[1];
  final input = ReceivePort();
  handshake.send(input.sendPort);
  final analyzer = FourierImageAnalyzer();
  Float64List? previousPower;
  input.listen((dynamic message) {
    if (message is! List<Object?> || message.isEmpty) return;
    if (message[0] == 'close') {
      input.close();
      return;
    }
    if (message[0] != 'analyze') return;
    final id = message[1]! as int;
    try {
      final watch = Stopwatch()..start();
      final rgba =
          (message[3]! as TransferableTypedData).materialize().asUint8List();
      final analysis = analyzer.analyze(
        rgba: rgba,
        width: message[4]! as int,
        height: message[5]! as int,
        maxDimension: message[6]! as int,
        removeDc: message[7]! as bool,
        applyHann: message[8]! as bool,
        alphaRepresentation: RgbaAlphaRepresentation.premultiplied,
        previousPower: previousPower,
      );
      previousPower = analysis.power;
      final spectrumRgba = _renderSpectrum(
        analysis.power,
        analysis.spectrum.width,
        analysis.spectrum.height,
      );
      watch.stop();
      parent.send(<Object?>[
        'result',
        id,
        message[2]! as int,
        TransferableTypedData.fromList([spectrumRgba]),
        analysis.spectrum.width,
        analysis.spectrum.height,
        _encodeFeatures(analysis.features),
        analysis.isBlank,
        watch.elapsedMicroseconds,
      ]);
    } catch (error, stack) {
      parent.send(<Object?>['error', id, '$error\n$stack']);
    }
  });
}

Uint8List _renderSpectrum(Float64List power, int width, int height) {
  final logValues = Float64List(power.length);
  for (var index = 0; index < power.length; index++) {
    logValues[index] = math.log(1 + math.max(0, power[index]));
  }
  final ordered = logValues.toList()..sort();
  final percentileIndex = ((ordered.length - 1) * 0.995).round();
  final scale = ordered[percentileIndex];
  final output = Uint8List(power.length * 4);
  for (var y = 0; y < height; y++) {
    final sourceY = (y - height ~/ 2) % height;
    for (var x = 0; x < width; x++) {
      final sourceX = (x - width ~/ 2) % width;
      final source = sourceY * width + sourceX;
      final value =
          scale <= 0 ? 0.0 : (logValues[source] / scale).clamp(0.0, 1.0);
      final color = _spectrumColor(value);
      final target = (y * width + x) * 4;
      output[target] = color.$1;
      output[target + 1] = color.$2;
      output[target + 2] = color.$3;
      output[target + 3] = 255;
    }
  }
  return output;
}

(int, int, int) _spectrumColor(double value) {
  if (value < 1 / 3) {
    return _mix((0, 0, 8), (58, 16, 120), value * 3);
  }
  if (value < 2 / 3) {
    return _mix((58, 16, 120), (25, 100, 220), (value - 1 / 3) * 3);
  }
  return _mix((25, 100, 220), (230, 245, 255), (value - 2 / 3) * 3);
}

(int, int, int) _mix((int, int, int) a, (int, int, int) b, double t) => (
      (a.$1 + (b.$1 - a.$1) * t).round(),
      (a.$2 + (b.$2 - a.$2) * t).round(),
      (a.$3 + (b.$3 - a.$3) * t).round(),
    );

List<Object?> _encodeFeatures(FourierSpectrumFeatures value) => <Object?>[
      value.radialBandPower,
      value.lowPowerRatio,
      value.midPowerRatio,
      value.highPowerRatio,
      value.centroid,
      value.bandwidth,
      value.rolloff85,
      value.logPowerSlope,
      value.radialPeakSalience,
      value.entropy,
      value.flatness,
      value.dominantOrientation,
      value.orientationStrength,
      value.spectralFlux,
      value.captureMean,
      value.captureVariance,
      value.alphaCoverage,
      value.width,
      value.height,
      value.windowApplied,
      value.dcRemoved,
    ];

FourierSpectrumFeatures _decodeFeatures(List<Object?> values) =>
    FourierSpectrumFeatures(
      radialBandPower: (values[0]! as List<Object?>).cast<double>(),
      lowPowerRatio: values[1]! as double,
      midPowerRatio: values[2]! as double,
      highPowerRatio: values[3]! as double,
      centroid: values[4]! as double,
      bandwidth: values[5]! as double,
      rolloff85: values[6]! as double,
      logPowerSlope: values[7]! as double,
      radialPeakSalience: values[8]! as double,
      entropy: values[9]! as double,
      flatness: values[10]! as double,
      dominantOrientation: values[11]! as double,
      orientationStrength: values[12]! as double,
      spectralFlux: values[13]! as double,
      captureMean: values[14]! as double,
      captureVariance: values[15]! as double,
      alphaCoverage: values[16]! as double,
      width: values[17]! as int,
      height: values[18]! as int,
      windowApplied: values[19]! as bool,
      dcRemoved: values[20]! as bool,
    );
