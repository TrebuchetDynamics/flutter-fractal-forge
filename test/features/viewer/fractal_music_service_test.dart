import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';

bool _pcmHasSignal(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  for (var offset = 44; offset + 1 < wav.length; offset += 2) {
    if (data.getInt16(offset, Endian.little) != 0) return true;
  }
  return false;
}

int _wavChannels(Uint8List wav) =>
    ByteData.sublistView(wav).getUint16(22, Endian.little);

int _pcmSample(Uint8List wav, int sampleIndex, {int channel = 0}) {
  final channels = _wavChannels(wav);
  return ByteData.sublistView(wav).getInt16(
    44 + (sampleIndex * channels + channel) * 2,
    Endian.little,
  );
}

int _pcmPeak(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  var peak = 0;
  for (var offset = 44; offset + 1 < wav.length; offset += 2) {
    final sample = data.getInt16(offset, Endian.little).abs();
    if (sample > peak) peak = sample;
  }
  return peak;
}

double _pcmMeanAbsOffset(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  var sum = 0;
  var count = 0;
  for (var offset = 44; offset + 1 < wav.length; offset += 2) {
    sum += data.getInt16(offset, Endian.little);
    count++;
  }
  return count == 0 ? 0 : (sum / count).abs();
}

double _pcmRms(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  var sumSquares = 0.0;
  var count = 0;
  for (var offset = 44; offset + 1 < wav.length; offset += 2) {
    final sample = data.getInt16(offset, Endian.little);
    sumSquares += sample * sample;
    count++;
  }
  return count == 0 ? 0 : math.sqrt(sumSquares / count);
}

int _wavSampleRate(Uint8List wav) =>
    ByteData.sublistView(wav).getUint32(24, Endian.little);

int _wavDataBytes(Uint8List wav) =>
    ByteData.sublistView(wav).getUint32(40, Endian.little);

int _pcmChannelEnergy(
  Uint8List wav, {
  required int startFrame,
  required int endFrame,
  required int channel,
}) {
  final channels = _wavChannels(wav);
  final data = ByteData.sublistView(wav);
  var energy = 0;
  for (var frame = startFrame; frame < endFrame; frame++) {
    final offset = 44 + (frame * channels + channel) * 2;
    energy += data.getInt16(offset, Endian.little).abs();
  }
  return energy;
}

int _maxAdjacentMonoDelta(Uint8List wav) {
  final channels = _wavChannels(wav);
  final data = ByteData.sublistView(wav);
  int? previous;
  var maxDelta = 0;
  for (var frame = 0;
      44 + (frame * channels + channels - 1) * 2 + 1 < wav.length;
      frame++) {
    var sum = 0;
    for (var channel = 0; channel < channels; channel++) {
      sum +=
          data.getInt16(44 + (frame * channels + channel) * 2, Endian.little);
    }
    final mono = sum ~/ channels;
    final last = previous;
    if (last != null) {
      final delta = (mono - last).abs();
      if (delta > maxDelta) maxDelta = delta;
    }
    previous = mono;
  }
  return maxDelta;
}

Uint8List _solidFrame(int width, int height, int r, int g, int b) {
  final frame = Uint8List(width * height * 4);
  for (var i = 0; i < width * height; i++) {
    final offset = i * 4;
    frame[offset] = r;
    frame[offset + 1] = g;
    frame[offset + 2] = b;
    frame[offset + 3] = 255;
  }
  return frame;
}

Uint8List _angledRayFrame({int size = 65, required double degrees}) {
  final frame = Uint8List(size * size * 4);
  final center = (size - 1) / 2;
  final angle = degrees * math.pi / 180;
  for (var radius = size * 0.28; radius <= center; radius += 0.5) {
    final x = (center + math.cos(angle) * radius).round();
    final y = (center + math.sin(angle) * radius).round();
    final offset = (y * size + x) * 4;
    frame[offset] = 255;
    frame[offset + 1] = 255;
    frame[offset + 2] = 255;
    frame[offset + 3] = 255;
  }
  return frame;
}

class _FakeProcess implements Process {
  _FakeProcess(this.code);

  final int code;

  @override
  Future<int> get exitCode => Future.value(code);

  @override
  int get pid => 1234;

  @override
  IOSink get stdin => throw UnimplementedError();

  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildFractalMusicWav writes deterministic wav audio', () {
    final a = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'iterations': 120, 'colorScheme': 2},
      panX: -0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );
    final b = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'colorScheme': 2, 'iterations': 120},
      panX: -0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );
    final c = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'iterations': 120, 'colorScheme': 2},
      panX: 0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(String.fromCharCodes(a.take(4)), 'RIFF');
    expect(String.fromCharCodes(a.skip(8).take(4)), 'WAVE');
    expect(a.length, 44 + 8000 * 4);
    expect(_wavChannels(a), 2);
    expect(a, b);
    expect(a, isNot(c));
  });

  test('default audio duration matches the visible scan loop duration', () {
    const sampleRate = 1000;
    final stateLoop = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {},
      panX: 0,
      panY: 0,
      zoom: 1,
      sampleRate: sampleRate,
    );
    final scanLoop = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(4, 4, 120, 120, 120),
        width: 4,
        height: 4,
      ),
      zoom: 1,
      sampleRate: sampleRate,
    );
    final expectedFrames =
        (sampleRate * fractalMusicLoopDuration.inMilliseconds / 1000).round();

    expect(stateLoop.length, 44 + expectedFrames * _wavChannels(stateLoop) * 2);
    expect(scanLoop.length, 44 + expectedFrames * _wavChannels(scanLoop) * 2);
  });

  test('buildFractalMusicWav handles short loops below step count', () {
    final wav = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {},
      panX: 0,
      panY: 0,
      zoom: 1,
      sampleRate: 8,
      seconds: 1,
    );

    expect(String.fromCharCodes(wav.take(4)), 'RIFF');
    expect(wav.length, 44 + 8 * 4);
    expect(_wavChannels(wav), 2);
    expect(_pcmHasSignal(wav), isTrue);
  });

  test('fallback state audio has healthy stereo structure and amplitude', () {
    final wav = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'iterations': 180, 'colorScheme': 5},
      panX: -0.7435,
      panY: 0.1314,
      zoom: 12,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(_wavChannels(wav), 2);
    expect(_wavSampleRate(wav), 8000);
    expect(_wavDataBytes(wav), wav.length - 44);
    expect(_pcmPeak(wav), inInclusiveRange(1000, 7000));
    expect(_pcmMeanAbsOffset(wav), lessThan(80));
    expect(_pcmSample(wav, 0, channel: 0), 0);
    expect(_pcmSample(wav, 0, channel: 1), 0);
    expect(_pcmSample(wav, 7999, channel: 0), 0);
    expect(_pcmSample(wav, 7999, channel: 1), 0);
    expect(
      _pcmChannelEnergy(wav, startFrame: 0, endFrame: 8000, channel: 0),
      isNot(_pcmChannelEnergy(wav, startFrame: 0, endFrame: 8000, channel: 1)),
    );
  });

  test('generated loops start and end silent to avoid loop clicks', () {
    final stateLoop = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'iterations': 120},
      panX: -0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );
    final scanLoop = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: Uint8List.fromList(List.filled(8 * 8 * 4, 180)),
        width: 8,
        height: 8,
      ),
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(_pcmSample(stateLoop, 0, channel: 0), 0);
    expect(_pcmSample(stateLoop, 0, channel: 1), 0);
    expect(_pcmSample(stateLoop, 7999, channel: 0), 0);
    expect(_pcmSample(stateLoop, 7999, channel: 1), 0);
    expect(_pcmSample(scanLoop, 0), 0);
    expect(_pcmSample(scanLoop, 7999), 0);
  });

  test('buildFractalMusicScanWav leaves empty space silent', () {
    final dark = Uint8List(4 * 4 * 4);
    final bright = Uint8List.fromList(List.filled(4 * 4 * 4, 255));

    final a = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: dark, width: 4, height: 4),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final b = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: bright, width: 4, height: 4),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(String.fromCharCodes(a.take(4)), 'RIFF');
    expect(a.length, 44 + 8000 * 4);
    expect(_wavChannels(a), 2);
    expect(_pcmHasSignal(a), isFalse);
    expect(_pcmHasSignal(b), isTrue);
  });

  test('scan frame signature catches localized visual changes', () {
    final a = Uint8List(8 * 8 * 4);
    final b = Uint8List(8 * 8 * 4);
    for (var i = 0; i < 8 * 8; i++) {
      a[i * 4 + 3] = 255;
      b[i * 4 + 3] = 255;
    }
    b[(7 * 8 + 7) * 4] = 255;

    final first = FractalMusicScanFrame(rgba: a, width: 8, height: 8);
    final second = FractalMusicScanFrame(rgba: b, width: 8, height: 8);

    expect(first.visualSignature, isNot(second.visualSignature));
  });

  test('scan profile follows the scanner cross-section angle', () {
    final frame = Uint8List(11 * 11 * 4);
    for (var x = 5; x < 11; x++) {
      final offset = (5 * 11 + x) * 4;
      frame[offset] = 255;
      frame[offset + 1] = 255;
      frame[offset + 2] = 255;
      frame[offset + 3] = 255;
    }

    final right = debugFractalMusicScanProfile(
      scanFrame: FractalMusicScanFrame(rgba: frame, width: 11, height: 11),
      step: 8,
      steps: 32,
    );
    final up = debugFractalMusicScanProfile(
      scanFrame: FractalMusicScanFrame(rgba: frame, width: 11, height: 11),
      step: 0,
      steps: 32,
    );

    expect(right.brightness, greaterThan(0.4));
    expect(up.brightness, lessThan(0.2));
  });

  test('scan profile default steps match the music scan right quarter', () {
    final frame = Uint8List(11 * 11 * 4);
    for (var x = 5; x < 11; x++) {
      final offset = (5 * 11 + x) * 4;
      frame[offset] = 255;
      frame[offset + 1] = 255;
      frame[offset + 2] = 255;
      frame[offset + 3] = 255;
    }

    final right = debugFractalMusicScanProfile(
      scanFrame: FractalMusicScanFrame(rgba: frame, width: 11, height: 11),
      step: 16,
    );

    expect(right.brightness, greaterThan(0.4));
  });

  test('scan audio catches detail between coarse scanner spokes', () {
    final frame = _angledRayFrame(degrees: 11.25);
    final scanFrame = FractalMusicScanFrame(rgba: frame, width: 65, height: 65);

    expect(
      debugFractalMusicScanProfile(
        scanFrame: scanFrame,
        step: 9,
        steps: 32,
      ).brightness,
      greaterThan(0.2),
    );

    final wav = buildFractalMusicScanWav(
      scanFrame: scanFrame,
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(_pcmHasSignal(wav), isTrue);
  });

  test('scan distance bins keep black spots silent and bright ranges active',
      () {
    final frame = Uint8List(17 * 17 * 4);
    for (var x = 13; x < 17; x++) {
      final offset = (8 * 17 + x) * 4;
      frame[offset] = 255;
      frame[offset + 1] = 255;
      frame[offset + 2] = 255;
      frame[offset + 3] = 255;
    }

    final bins = debugFractalMusicScanDistanceProfile(
      scanFrame: FractalMusicScanFrame(rgba: frame, width: 17, height: 17),
      step: 16,
    );

    expect(bins.first.brightness, lessThan(0.02));
    expect(bins.last.brightness, greaterThan(0.4));
    expect(
      debugFractalMusicDistanceMidi(distance: bins.first.distance, zoom: 1),
      lessThan(debugFractalMusicDistanceMidi(
        distance: bins.last.distance,
        zoom: 1,
      )),
    );
  });

  test('scan audio maps distance to different signatures', () {
    final near = Uint8List(17 * 17 * 4);
    final far = Uint8List(17 * 17 * 4);
    for (final x in [8, 9]) {
      final offset = (8 * 17 + x) * 4;
      near[offset] = 255;
      near[offset + 1] = 255;
      near[offset + 2] = 255;
      near[offset + 3] = 255;
    }
    for (final x in [15, 16]) {
      final offset = (8 * 17 + x) * 4;
      far[offset] = 255;
      far[offset + 1] = 255;
      far[offset + 2] = 255;
      far[offset + 3] = 255;
    }

    final nearWav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: near, width: 17, height: 17),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final farWav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: far, width: 17, height: 17),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(nearWav, isNot(farWav));
    expect(_pcmHasSignal(nearWav), isTrue);
    expect(_pcmHasSignal(farWav), isTrue);
  });

  test('scan profile keeps color as a visual music input', () {
    final red = debugFractalMusicScanProfile(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 255, 0, 0),
        width: 8,
        height: 8,
      ),
      step: 0,
    );
    final green = debugFractalMusicScanProfile(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 0, 76, 0),
        width: 8,
        height: 8,
      ),
      step: 0,
    );

    expect((red.brightness - green.brightness).abs(), lessThan(0.03));
    expect(red.saturation, greaterThan(0.9));
    expect(green.saturation, greaterThan(0.9));
    expect(red.hue, isNot(green.hue));
  });

  test('scan audio smooths abrupt visual transitions', () {
    final frame = Uint8List(16 * 16 * 4);
    for (var y = 0; y < 16; y++) {
      for (var x = 0; x < 16; x++) {
        final offset = (y * 16 + x) * 4;
        final bright = x >= 8;
        frame[offset] = bright ? 255 : 0;
        frame[offset + 1] = bright ? 255 : 0;
        frame[offset + 2] = bright ? 255 : 0;
        frame[offset + 3] = 255;
      }
    }

    final wav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: frame, width: 16, height: 16),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(_maxAdjacentMonoDelta(wav), lessThan(2500));
  });

  test('scan audio has healthy wav structure and amplitude', () {
    final wav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 120, 80, 200),
        width: 8,
        height: 8,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(String.fromCharCodes(wav.take(4)), 'RIFF');
    expect(_wavChannels(wav), 2);
    expect(_wavSampleRate(wav), 8000);
    expect(_wavDataBytes(wav), wav.length - 44);
    expect(_pcmPeak(wav), inInclusiveRange(1000, 7000));
    expect(_pcmMeanAbsOffset(wav), lessThan(80));
    expect(_pcmSample(wav, 0, channel: 0), 0);
    expect(_pcmSample(wav, 0, channel: 1), 0);
    expect(_pcmSample(wav, 7999, channel: 0), 0);
    expect(_pcmSample(wav, 7999, channel: 1), 0);
  });

  test('scan audio maps visual detail to stronger texture', () {
    final flat = _solidFrame(16, 16, 128, 128, 128);
    final detailed = Uint8List(16 * 16 * 4);
    for (var y = 0; y < 16; y++) {
      for (var x = 0; x < 16; x++) {
        final offset = (y * 16 + x) * 4;
        final value = ((x + y) % 2 == 0) ? 48 : 208;
        detailed[offset] = value;
        detailed[offset + 1] = value;
        detailed[offset + 2] = value;
        detailed[offset + 3] = 255;
      }
    }

    final flatWav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: flat, width: 16, height: 16),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final detailedWav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: detailed, width: 16, height: 16),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(detailedWav, isNot(flatWav));
    expect(_pcmRms(detailedWav), greaterThan(_pcmRms(flatWav)));
    expect(_pcmPeak(detailedWav), lessThan(7000));
  });

  test('scan audio maps visual brightness to loudness', () {
    final dim = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 40, 40, 40),
        width: 8,
        height: 8,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final bright = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 220, 220, 220),
        width: 8,
        height: 8,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(_pcmRms(bright), greaterThan(_pcmRms(dim) * 2));
    expect(_pcmPeak(bright), lessThan(7000));
  });

  test('scan audio is color-sensitive and peak-limited', () {
    final red = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 255, 0, 0),
        width: 8,
        height: 8,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final green = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 0, 76, 0),
        width: 8,
        height: 8,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(red, isNot(green));
    expect(_pcmPeak(red), lessThan(7000));
    expect(_pcmPeak(green), lessThan(7000));
  });

  test('scan audio pans with the visible scanner direction', () {
    final wav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 120, 120, 120),
        width: 8,
        height: 8,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(_wavChannels(wav), 2);
    final rightScanLeftEnergy = _pcmChannelEnergy(
      wav,
      startFrame: 2000,
      endFrame: 2250,
      channel: 0,
    );
    final rightScanRightEnergy = _pcmChannelEnergy(
      wav,
      startFrame: 2000,
      endFrame: 2250,
      channel: 1,
    );
    final leftScanLeftEnergy = _pcmChannelEnergy(
      wav,
      startFrame: 6000,
      endFrame: 6250,
      channel: 0,
    );
    final leftScanRightEnergy = _pcmChannelEnergy(
      wav,
      startFrame: 6000,
      endFrame: 6250,
      channel: 1,
    );

    expect(rightScanRightEnergy, greaterThan(rightScanLeftEnergy));
    expect(leftScanLeftEnergy, greaterThan(leftScanRightEnergy));
  });

  test('buildFractalMusicScanWav samples to the visible edge on wide views',
      () {
    final dark = Uint8List(100 * 11 * 4);
    final edgeBright = Uint8List(100 * 11 * 4);
    for (var y = 0; y < 11; y++) {
      for (var x = 80; x < 100; x++) {
        final offset = (y * 100 + x) * 4;
        edgeBright[offset] = 255;
        edgeBright[offset + 1] = 255;
        edgeBright[offset + 2] = 255;
        edgeBright[offset + 3] = 255;
      }
    }

    final a = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: dark, width: 100, height: 11),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final b = buildFractalMusicScanWav(
      scanFrame:
          FractalMusicScanFrame(rgba: edgeBright, width: 100, height: 11),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(a, isNot(b));
  });

  test('play reports missing Linux audio players before starting playback',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final service = FractalMusicService(commandExists: (_) async => false);
    addTearDown(service.dispose);

    await expectLater(
      service.play(controller),
      throwsA(isA<StateError>().having(
        (error) => error.message,
        'message',
        contains('No Linux audio player'),
      )),
    );
  });

  test('play reports audio device failure and cleans generated temp audio',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    Directory? createdDir;
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        createdDir = await tempRoot.createTemp(prefix);
        return createdDir!;
      },
      startProcess: (_, __) async => _FakeProcess(1),
    );
    addTearDown(service.dispose);

    await expectLater(
      service.play(controller),
      throwsA(isA<StateError>().having(
        (error) => error.message,
        'message',
        contains('audio playback failed'),
      )),
    );

    expect(createdDir, isNotNull);
    expect(createdDir!.existsSync(), isFalse);
  });

  test('web play sends generated wav bytes to browser audio player', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final calls = <String>[];
    Uint8List? playedBytes;
    final service = FractalMusicService(
      isWeb: true,
      isAndroid: false,
      isLinux: false,
      webPlay: (bytes) async {
        calls.add('play');
        playedBytes = bytes;
        return true;
      },
      webStop: () async => calls.add('stop'),
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await service.stop();

    expect(calls, ['stop', 'play', 'stop']);
    expect(String.fromCharCodes(playedBytes!.take(4)), 'RIFF');
  });

  test('Android play sends generated wav bytes to the native audio channel',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    const channel = MethodChannel('test/fractal_music');
    final calls = <String>[];
    Uint8List? playedBytes;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'play') {
        playedBytes = (call.arguments as Map)['bytes'] as Uint8List;
        return true;
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final service = FractalMusicService(
      androidChannel: channel,
      isAndroid: true,
      isLinux: false,
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await service.stop();

    expect(calls, ['stop', 'play', 'stop']);
    expect(String.fromCharCodes(playedBytes!.take(4)), 'RIFF');
    expect(_wavChannels(playedBytes!), 2);
    expect(_wavDataBytes(playedBytes!), playedBytes!.length - 44);
  });

  test('Linux playback loop kills active child player on stop', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    String? executable;
    List<String>? arguments;
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) => tempRoot.createTemp(prefix),
      startProcess: (exe, args) async {
        executable = exe;
        arguments = args;
        return _FakeProcess(-1);
      },
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await service.stop();

    expect(executable, 'sh');
    final command = arguments?[1] ?? '';
    expect(command, contains('trap cleanup TERM INT EXIT'));
    expect(command, contains('status=\$?'));
    expect(command, contains('kill "\$child"'));
    expect(command, contains('exit "\$status"'));
    expect(command, contains('wait "\$child"'));
  });

  test('play cleans temp audio when Linux player process cannot start',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    Directory? createdDir;
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        createdDir = await tempRoot.createTemp(prefix);
        return createdDir!;
      },
      startProcess: (_, __) async => throw StateError('cannot start player'),
    );
    addTearDown(service.dispose);

    await expectLater(service.play(controller), throwsStateError);

    expect(createdDir, isNotNull);
    expect(createdDir!.existsSync(), isFalse);
  });

  test('play creates unique temp directories for separate sessions', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    final created = <String>[];
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        final dir = await tempRoot.createTemp(prefix);
        created.add(dir.path);
        return dir;
      },
      startProcess: (_, __) async => _FakeProcess(-1),
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await service.stop();
    await service.play(controller);
    await service.stop();

    expect(created, hasLength(2));
    expect(created.toSet(), hasLength(2));
  });
}
