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

int _pcmZeroCrossings(Uint8List wav) {
  final channels = _wavChannels(wav);
  final data = ByteData.sublistView(wav);
  var crossings = 0;
  var previous = _pcmSample(wav, 0);
  for (var frame = 1;
      44 + (frame * channels + channels - 1) * 2 + 1 < wav.length;
      frame++) {
    final sample = data.getInt16(44 + frame * channels * 2, Endian.little);
    if ((previous < 0 && sample >= 0) || (previous > 0 && sample <= 0)) {
      crossings++;
    }
    previous = sample;
  }
  return crossings;
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

class _TrackingScanFrame extends FractalMusicScanFrame {
  _TrackingScanFrame(this.onFirstValidation)
      : super(rgba: _solidFrame(1, 1, 120, 120, 120), width: 1, height: 1);

  final void Function() onFirstValidation;
  bool _recorded = false;

  @override
  bool get isValid {
    if (!_recorded) {
      _recorded = true;
      onFirstValidation();
    }
    return super.isValid;
  }
}

class _FakeProcess implements Process {
  _FakeProcess(
    this.code, {
    this.exitError,
    this.killError,
    this.killResult = true,
  });

  final int code;
  final Object? exitError;
  final Object? killError;
  final bool killResult;
  bool killed = false;

  @override
  Future<int> get exitCode {
    final error = exitError;
    return error == null ? Future.value(code) : Future.error(error);
  }

  @override
  int get pid => 1234;

  @override
  IOSink get stdin => throw UnimplementedError();

  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    final error = killError;
    if (error != null) throw error;
    return killResult;
  }
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

  test('default audio and visible scanner share a slower 24-second loop', () {
    const sampleRate = 1000;
    expect(fractalMusicLoopSeconds, 24);
    expect(fractalMusicLoopDuration, const Duration(seconds: 24));
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

  test('sustained voices carry across beat boundaries', () {
    const sampleRate = 8000;
    const seconds = 4;
    final wav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: _solidFrame(8, 8, 200, 200, 200),
        width: 8,
        height: 8,
      ),
      zoom: 1,
      sampleRate: sampleRate,
      seconds: seconds.toDouble(),
    );

    final overall = _pcmRms(wav);
    expect(overall, greaterThan(0));

    // Bass and pad hold through the bar, so no beat boundary may duck the whole
    // mix toward silence the way a single shared envelope did.
    final bpm = debugFractalMusicTempoBpm(0);
    final beats = (bpm * seconds / 60).round();
    for (var beat = 1; beat < beats; beat++) {
      final boundary = beat * sampleRate * seconds ~/ beats;
      var sumSquares = 0.0;
      var count = 0;
      for (var frame = boundary - 60; frame < boundary + 60; frame++) {
        if (frame < 0 || frame >= sampleRate * seconds) continue;
        final sample = _pcmSample(wav, frame);
        sumSquares += sample * sample;
        count++;
      }
      final boundaryRms = math.sqrt(sumSquares / count);
      expect(
        boundaryRms,
        greaterThan(overall * 0.25),
        reason: 'beat $beat boundary ducked to $boundaryRms vs overall $overall',
      );
    }
  });

  test('image detail selects a tempo band across the usable range', () {
    // The measured corpus runs 0.005-0.53 collapsed detail with a median near
    // 0.06, so that range has to reach both ends of the band table rather than
    // pinning to the slowest.
    expect(debugFractalMusicTempoBpm(0.0), 60);
    expect(debugFractalMusicTempoBpm(0.30), 100);
    final mid = debugFractalMusicTempoBpm(0.06);
    expect(mid, greaterThan(60));
    expect(mid, lessThan(100));
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

  test('scan audio maps visual brightness to loudness and harmony', () {
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
    expect(
        _pcmZeroCrossings(bright), greaterThan(_pcmZeroCrossings(dim) * 1.03));
    expect(_pcmPeak(bright), lessThan(7000));
  });

  test('scan audio maps dominant hue to a chromatic root', () {
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

    expect(_pcmZeroCrossings(green), greaterThan(_pcmZeroCrossings(red) * 1.1));
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

  FractalMusicFeatures features({
    double brightness = 0.2,
    double detail = 0.05,
    double hue = 0.0,
    double saturation = 0.5,
  }) =>
      FractalMusicFeatures(
        brightness: brightness,
        detail: detail,
        hue: hue,
        saturation: saturation,
      );

  test('mode holds through a nudge and flips once it clears the band', () {
    final start = resolveFractalMusicIdentity(features(brightness: 0.28));
    expect(start.major, isFalse);

    // Past the raw edge but still inside the hysteresis band: hold.
    expect(
      resolveFractalMusicIdentity(
        features(brightness: 0.32),
        previous: start,
      ).major,
      isFalse,
    );

    expect(
      resolveFractalMusicIdentity(
        features(brightness: 0.35),
        previous: start,
      ).major,
      isTrue,
    );
  });

  test('key holds under small hue drift, including across the wrap', () {
    final start = resolveFractalMusicIdentity(features(hue: 0.0));
    expect(start.rootSemitones, 0);

    expect(
      resolveFractalMusicIdentity(features(hue: 0.08), previous: start)
          .rootSemitones,
      0,
    );
    // Hue just below the wrap is 0.6 semitones away, not 11.4.
    expect(
      resolveFractalMusicIdentity(features(hue: 0.95), previous: start)
          .rootSemitones,
      0,
    );
    expect(
      resolveFractalMusicIdentity(features(hue: 0.2), previous: start)
          .rootSemitones,
      2,
    );
  });

  test('tempo holds through a nudge across a detail band edge', () {
    final start = resolveFractalMusicIdentity(features(detail: 0.02));
    expect(start.bpm, 60);

    // Tempo bands are only ~0.015 wide, so they carry a much tighter margin
    // than mode or register; the nudge that holds has to be correspondingly
    // small.
    expect(
      resolveFractalMusicIdentity(features(detail: 0.042), previous: start).bpm,
      60,
    );
    expect(
      resolveFractalMusicIdentity(features(detail: 0.05), previous: start).bpm,
      greaterThan(60),
    );
  });

  test('feature comparison ignores nudges and catches real changes', () {
    FractalMusicFeatures of(int value) => fractalMusicFeaturesOf(
          FractalMusicScanFrame(
            rgba: _solidFrame(8, 8, value, value, value),
            width: 8,
            height: 8,
          ),
        );

    expect(of(120).differsFrom(of(122)), isFalse);
    expect(of(120).differsFrom(of(220)), isTrue);
  });

  test('an explicit identity overrides what the frame would have chosen', () {
    final frame = FractalMusicScanFrame(
      rgba: _solidFrame(8, 8, 120, 80, 200),
      width: 8,
      height: 8,
    );
    final fromFrame = buildFractalMusicScanWav(
      scanFrame: frame,
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final forced = buildFractalMusicScanWav(
      scanFrame: frame,
      zoom: 1,
      identity: const FractalMusicIdentity(
        rootSemitones: 7,
        major: true,
        registerSemitones: 12,
        bpm: 90,
        progressionIndex: 3,
      ),
      sampleRate: 8000,
      seconds: 1,
    );

    expect(fromFrame, isNot(forced));
  });

  test('every banked progression is tonic-rooted and stays in its mode', () {
    // Catches a typo in the tables: a progression that starts somewhere other
    // than the tonic, or borrows a chord from outside the mode, would make the
    // loop point stop resolving.
    const majorDegrees = {0, 2, 4, 5, 7, 9, 11};
    const minorDegrees = {0, 2, 3, 5, 7, 8, 10};

    expect(debugFractalMusicProgressionCount, 8);
    for (final major in [true, false]) {
      final allowed = major ? majorDegrees : minorDegrees;
      final seen = <String>{};
      for (var index = 0; index < debugFractalMusicProgressionCount; index++) {
        final progression =
            debugFractalMusicProgression(major: major, index: index);
        expect(progression.length, 4, reason: 'index $index');
        expect(progression.first, 0, reason: 'index $index must start on I/i');
        for (final degree in progression) {
          expect(allowed, contains(degree), reason: 'index $index');
        }
        expect(seen.add(progression.join(',')), isTrue,
            reason: 'index $index duplicates an earlier progression');
      }
    }
  });

  test('saturation selects the progression and holds through a nudge', () {
    FractalMusicFeatures withSaturation(double saturation) =>
        FractalMusicFeatures(
          brightness: 0.2,
          detail: 0.05,
          hue: 0.0,
          saturation: saturation,
        );

    final low = resolveFractalMusicIdentity(withSaturation(0.05));
    expect(low.progressionIndex, 0);
    expect(resolveFractalMusicIdentity(withSaturation(0.10)).progressionIndex,
        greaterThan(0));

    // Just past the edge but inside the tighter progression band: hold.
    expect(
      resolveFractalMusicIdentity(withSaturation(0.08), previous: low)
          .progressionIndex,
      0,
    );
    expect(
      resolveFractalMusicIdentity(withSaturation(0.09), previous: low)
          .progressionIndex,
      1,
    );
  });

  test('different progressions produce different audio', () {
    final frame = FractalMusicScanFrame(
      rgba: _solidFrame(8, 8, 120, 80, 200),
      width: 8,
      height: 8,
    );
    Uint8List render(int progressionIndex) => buildFractalMusicScanWav(
          scanFrame: frame,
          zoom: 1,
          identity: FractalMusicIdentity(
            rootSemitones: 0,
            major: true,
            registerSemitones: 12,
            bpm: 60,
            progressionIndex: progressionIndex,
          ),
          sampleRate: 8000,
          // Needs at least four bars, or the loop never leaves the tonic that
          // every progression starts on. The 24s production loop holds 6-10.
          seconds: 16,
        );

    expect(render(0), isNot(render(1)));
    expect(render(0), isNot(render(7)));
  });

  test('motion measures how far the image travelled', () {
    const base = FractalMusicFeatures(
      brightness: 0.3,
      detail: 0.05,
      hue: 0.1,
      saturation: 0.4,
    );
    expect(base.motionFrom(base), 0);

    const brighter = FractalMusicFeatures(
      brightness: 0.6,
      detail: 0.05,
      hue: 0.1,
      saturation: 0.4,
    );
    expect(base.motionFrom(brighter), closeTo(0.3, 1e-9));

    // Hue wraps: 0.98 and 0.02 are 0.04 apart, not 0.96.
    const nearWrapLow = FractalMusicFeatures(
      brightness: 0.3,
      detail: 0.05,
      hue: 0.98,
      saturation: 0.4,
    );
    const nearWrapHigh = FractalMusicFeatures(
      brightness: 0.3,
      detail: 0.05,
      hue: 0.02,
      saturation: 0.4,
    );
    expect(nearWrapLow.motionFrom(nearWrapHigh), closeTo(0.08, 1e-9));
  });

  test('motion turns the bar-closing rest into a pickup fill', () {
    final frame = FractalMusicScanFrame(
      rgba: _solidFrame(8, 8, 120, 80, 200),
      width: 8,
      height: 8,
    );
    Uint8List render(double motion) => buildFractalMusicScanWav(
          scanFrame: frame,
          zoom: 1,
          identity: const FractalMusicIdentity(
            rootSemitones: 0,
            major: true,
            registerSemitones: 12,
            bpm: 60,
            progressionIndex: 0,
          ),
          motion: motion,
          sampleRate: 8000,
          // Four bars, so the closing beat of a full bar actually exists.
          seconds: 16,
        );

    final still = render(0);
    expect(
      render(0.02),
      still,
      reason: 'below the threshold the bar keeps its rest',
    );

    final moving = render(0.4);
    expect(moving, isNot(still));
    expect(_pcmRms(moving), greaterThan(_pcmRms(still)));
    expect(_pcmPeak(moving), lessThan(7000));
    expect(_pcmSample(moving, 0), 0);
    expect(_pcmSample(moving, 8000 * 16 - 1), 0);
  });

  test('a dark region holds the chord instead of dropping out', () {
    // Bright centre, black outer ring: a Mandelbrot is mostly black, so bars
    // the beam finds nothing in must still carry pad and bass. Only a wholly
    // empty frame is silent.
    const size = 41;
    final frame = Uint8List(size * size * 4);
    final centre = (size - 1) / 2;
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final dx = x - centre;
        final dy = y - centre;
        final lit = math.sqrt(dx * dx + dy * dy) < size * 0.22;
        final offset = (y * size + x) * 4;
        frame[offset] = lit ? 230 : 0;
        frame[offset + 1] = lit ? 200 : 0;
        frame[offset + 2] = lit ? 120 : 0;
        frame[offset + 3] = 255;
      }
    }

    final wav = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: frame,
        width: size,
        height: size,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 8,
    );

    final frames = 8000 * 8;
    var nonZero = 0;
    for (var i = 0; i < frames; i++) {
      if (_pcmSample(wav, i) != 0) nonZero++;
    }
    expect(
      nonZero / frames,
      greaterThan(0.85),
      reason: 'dark bars should sustain, not go silent',
    );

    // A frame with nothing in it at all still produces nothing.
    final empty = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: Uint8List(size * size * 4),
        width: size,
        height: size,
      ),
      zoom: 1,
      sampleRate: 8000,
      seconds: 8,
    );
    expect(_pcmHasSignal(empty), isFalse);
  });

  test('unsupported platforms fail before generating audio', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    var generated = false;
    final service = FractalMusicService(
      isWeb: false,
      isAndroid: false,
      isLinux: false,
    );
    addTearDown(service.dispose);

    await expectLater(
      service.play(
        controller,
        scanFrame: _TrackingScanFrame(() => generated = true),
      ),
      throwsStateError,
    );

    expect(generated, isFalse);
  });

  test('missing Linux players fail before generating audio', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    var generated = false;
    final service = FractalMusicService(commandExists: (_) async => false);
    addTearDown(service.dispose);

    await expectLater(
      service.play(
        controller,
        scanFrame: _TrackingScanFrame(() => generated = true),
      ),
      throwsA(isA<StateError>().having(
        (error) => error.message,
        'message',
        contains('No Linux audio player'),
      )),
    );
    expect(generated, isFalse);
  });

  test('Linux preflight failure stops the previous loop', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    var playerAvailable = true;
    final process = _FakeProcess(-1);
    Directory? playingDir;
    final service = FractalMusicService(
      commandExists: (_) async => playerAvailable,
      createTempDir: (prefix) async {
        playingDir = await tempRoot.createTemp(prefix);
        return playingDir!;
      },
      startProcess: (_, __) async => process,
    );
    addTearDown(service.dispose);

    await service.play(controller);
    playerAvailable = false;
    await expectLater(service.play(controller), throwsStateError);

    expect(process.killed, isTrue);
    expect(playingDir!.existsSync(), isFalse);
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

  test('play generates replacement audio before stopping the current loop',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final calls = <String>[];
    final service = FractalMusicService(
      isWeb: true,
      isAndroid: false,
      isLinux: false,
      webPlay: (_) async {
        calls.add('play');
        return true;
      },
      webStop: () async => calls.add('stop'),
    );
    addTearDown(service.dispose);

    await service.play(
      controller,
      scanFrame: _TrackingScanFrame(() => calls.add('generate')),
    );

    expect(calls.take(3), ['generate', 'stop', 'play']);
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

  test('Linux stop reports failed kill signals after cleaning temp audio',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    Directory? createdDir;
    final process = _FakeProcess(-1, killResult: false);
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        createdDir = await tempRoot.createTemp(prefix);
        return createdDir!;
      },
      startProcess: (_, __) async => process,
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await expectLater(service.stop(), throwsStateError);

    expect(createdDir!.existsSync(), isFalse);
  });

  test('Linux dispose tolerates kill errors and cleans temp audio', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    Directory? createdDir;
    final process = _FakeProcess(
      -1,
      killError: StateError('cannot signal player'),
    );
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        createdDir = await tempRoot.createTemp(prefix);
        return createdDir!;
      },
      startProcess: (_, __) async => process,
    );

    await service.play(controller);

    expect(service.dispose, returnsNormally);
    expect(createdDir!.existsSync(), isFalse);
  });

  test('play cleans temp audio when writing the WAV fails', () async {
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
        await Directory('${createdDir!.path}/loop.wav').create();
        return createdDir!;
      },
      startProcess: (_, __) async => _FakeProcess(-1),
    );
    addTearDown(service.dispose);

    await expectLater(
      service.play(controller),
      throwsA(isA<FileSystemException>()),
    );

    expect(createdDir, isNotNull);
    expect(createdDir!.existsSync(), isFalse);
  });

  test('play cleans Linux resources when exit status cannot be read', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    Directory? createdDir;
    final process = _FakeProcess(
      -1,
      exitError: StateError('cannot read exit status'),
    );
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        createdDir = await tempRoot.createTemp(prefix);
        return createdDir!;
      },
      startProcess: (_, __) async => process,
    );
    addTearDown(service.dispose);

    await expectLater(service.play(controller), throwsStateError);

    expect(process.killed, isTrue);
    expect(createdDir, isNotNull);
    expect(createdDir!.existsSync(), isFalse);
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
