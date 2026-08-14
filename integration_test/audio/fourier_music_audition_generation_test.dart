import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_image_analyzer.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/audio/fourier_music_features.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

const _enabled = bool.fromEnvironment('GENERATE_FOURIER_AUDITIONS');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generate verified three-minute Fourier Music A/B auditions',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    controller.selectModule(controller.registry.byId('mandelbrot'),
        animate: false);

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 160,
            child: ChangeNotifierProvider<FractalController>.value(
              value: controller,
              child: FractalRenderer(
                boundaryKey: boundaryKey,
                animationEnabled: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    expect(boundary, isNotNull);
    final image = await boundary!.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    expect(data, isNotNull);
    final rgba = Uint8List.fromList(
      data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final scan = FractalMusicScanFrame(rgba: rgba, width: 160, height: 160);
    final analysis = FourierImageAnalyzer().analyze(
      rgba: rgba,
      width: 160,
      height: 160,
      maxDimension: 128,
      removeDc: true,
      applyHann: true,
    );
    expect(analysis.isBlank, isFalse);
    final measured = analysis.features;
    final fourier = const FourierMusicFeatureMapper().map(
      FourierMusicSpectrumFrame(
        lowPowerRatio: measured.lowPowerRatio,
        midPowerRatio: measured.midPowerRatio,
        highPowerRatio: measured.highPowerRatio,
        centroid: measured.centroid,
        entropy: measured.entropy,
        flatness: measured.flatness,
        orientation: measured.dominantOrientation,
        anisotropy: measured.orientationStrength,
        spectralFlux: measured.spectralFlux,
      ),
    );
    final baseFeatures = fractalMusicFeaturesOf(scan);
    final identity = resolveFractalMusicIdentity(baseFeatures);
    const sampleRate = 32000;
    const seconds = 180.0;
    final a = buildFractalMusicScanWav(
      scanFrame: scan,
      zoom: 1,
      identity: identity,
      sampleRate: sampleRate,
      seconds: seconds,
    );
    final b = buildFractalMusicScanWav(
      scanFrame: scan,
      zoom: 1,
      identity: identity,
      fourierFeatures: fourier,
      sampleRate: sampleRate,
      seconds: seconds,
    );
    expect(a, isNot(equals(b)));

    final outputPath = Platform.environment['FOURIER_AUDITION_DIR'];
    if (outputPath == null || outputPath.isEmpty) {
      throw StateError(
        'FOURIER_AUDITION_DIR is required when audition generation is enabled.',
      );
    }
    final output = Directory(outputPath)..createSync(recursive: true);
    final aFile = File('${output.path}/mandelbrot-scan-music-A-180s.wav')
      ..writeAsBytesSync(a, flush: true);
    final bFile = File('${output.path}/mandelbrot-fourier-music-B-180s.wav')
      ..writeAsBytesSync(b, flush: true);
    final events = debugFractalMusicScanScoreEvents(
      scanFrame: scan,
      zoom: 1,
      identity: identity,
      fourierFeatures: fourier,
      sampleRate: sampleRate,
      seconds: seconds,
    );
    final voices = <String, int>{};
    for (final event in events) {
      voices.update(event.voice, (count) => count + 1, ifAbsent: () => 1);
    }
    final metrics = {
      'sourceModule': controller.module.id,
      'seconds': seconds,
      'sampleRate': sampleRate,
      'identity': {
        'rootSemitones': identity.rootSemitones,
        'major': identity.major,
        'registerSemitones': identity.registerSemitones,
        'bpm': identity.bpm,
        'progressionIndex': identity.progressionIndex,
      },
      'spectrum': {
        'low': measured.lowPowerRatio,
        'mid': measured.midPowerRatio,
        'high': measured.highPowerRatio,
        'centroid': measured.centroid,
        'entropy': measured.entropy,
        'flatness': measured.flatness,
        'orientationRadians': measured.dominantOrientation,
        'anisotropy': measured.orientationStrength,
      },
      'voicesB': voices,
      'A': _pcmMetrics(a),
      'B': _pcmMetrics(b),
      'files': [aFile.path, bFile.path],
    };
    File('${output.path}/mandelbrot-fourier-music-metrics.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(metrics));
    expect((metrics['A']! as Map)['clippedSamples'], 0);
    expect((metrics['B']! as Map)['clippedSamples'], 0);
    expect(voices.keys.length, inInclusiveRange(4, 6));
    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(metrics));
  }, skip: !_enabled);
}

Map<String, Object> _pcmMetrics(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  var peak = 0;
  var clipped = 0;
  var sumSquares = 0.0;
  var samples = 0;
  for (var offset = 44; offset + 1 < wav.length; offset += 2) {
    final sample = data.getInt16(offset, Endian.little);
    final magnitude = sample.abs();
    if (magnitude > peak) peak = magnitude;
    if (sample == -32768 || sample == 32767) clipped++;
    final normalized = sample / 32768.0;
    sumSquares += normalized * normalized;
    samples++;
  }
  return {
    'bytes': wav.length,
    'samples': samples,
    'peak': peak / 32768.0,
    'rms': samples == 0 ? 0 : _sqrt(sumSquares / samples),
    'clippedSamples': clipped,
  };
}

double _sqrt(double value) {
  if (value <= 0) return 0;
  var estimate = value > 1 ? value : 1.0;
  for (var i = 0; i < 16; i++) {
    estimate = (estimate + value / estimate) / 2;
  }
  return estimate;
}
