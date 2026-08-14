import 'dart:typed_data';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/audio/fourier_music_features.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Fourier controls alter arrangement without changing key identity', () {
    final frame = _gradientFrame();
    const identity = FractalMusicIdentity(
      rootSemitones: 4,
      major: false,
      registerSemitones: 12,
      bpm: 80,
      progressionIndex: 1,
    );
    final low = const FourierMusicFeatureMapper().map(
      const FourierMusicSpectrumFrame(
        lowPowerRatio: 0.8,
        midPowerRatio: 0.15,
        highPowerRatio: 0.05,
        centroid: 0.1,
        entropy: 0.2,
        flatness: 0.1,
        orientation: 0,
        anisotropy: 0.8,
        spectralFlux: 0.1,
      ),
    );
    final high = const FourierMusicFeatureMapper().map(
      const FourierMusicSpectrumFrame(
        lowPowerRatio: 0.05,
        midPowerRatio: 0.15,
        highPowerRatio: 0.8,
        centroid: 0.9,
        entropy: 0.9,
        flatness: 0.8,
        orientation: 1.5707963267948966,
        anisotropy: 0.8,
        spectralFlux: 0.8,
      ),
    );

    final lowEvents = debugFractalMusicScanScoreEvents(
      scanFrame: frame,
      zoom: 1,
      identity: identity,
      fourierFeatures: low,
      sampleRate: 8000,
      seconds: 4,
    );
    final highEvents = debugFractalMusicScanScoreEvents(
      scanFrame: frame,
      zoom: 1,
      identity: identity,
      fourierFeatures: high,
      sampleRate: 8000,
      seconds: 4,
    );
    final lowLead = lowEvents.where((event) => event.voice == 'lead').toList();
    final highLead =
        highEvents.where((event) => event.voice == 'lead').toList();

    expect(lowLead, isNotEmpty);
    expect(highLead, isNotEmpty);
    expect(
      highLead.map((event) => event.midi).reduce((a, b) => a + b) /
          highLead.length,
      greaterThan(
        lowLead.map((event) => event.midi).reduce((a, b) => a + b) /
            lowLead.length,
      ),
    );
    expect(lowEvents.any((event) => event.voice == 'bass'), isTrue);
    expect(highEvents.any((event) => event.voice == 'percussion'), isTrue);

    final lowWav = buildFractalMusicScanWav(
      scanFrame: frame,
      zoom: 1,
      identity: identity,
      fourierFeatures: low,
      sampleRate: 8000,
      seconds: 4,
    );
    final highWav = buildFractalMusicScanWav(
      scanFrame: frame,
      zoom: 1,
      identity: identity,
      fourierFeatures: high,
      sampleRate: 8000,
      seconds: 4,
    );
    expect(lowWav, isNot(equals(highWav)));
    expect(_clippedSamples(lowWav), 0);
    expect(_clippedSamples(highWav), 0);
  });

  test('Fourier lead register moves pitched voices by octaves only', () {
    final frame = _gradientFrame();
    const identity = FractalMusicIdentity(
      rootSemitones: 4,
      major: false,
      registerSemitones: 12,
      bpm: 80,
      progressionIndex: 1,
    );
    const lowRegister = FourierMusicFeatures(
      bassWeight: 0.5,
      padOpenness: 0.5,
      highTexture: 0.5,
      leadRegister: 0,
      rhythmicComplexity: 0.5,
      stereoBias: 0,
      transitionStrength: 0.5,
      orientation: 0,
      anisotropy: 0.5,
      isSilent: false,
    );
    const highRegister = FourierMusicFeatures(
      bassWeight: 0.5,
      padOpenness: 0.5,
      highTexture: 0.5,
      leadRegister: 1,
      rhythmicComplexity: 0.5,
      stereoBias: 0,
      transitionStrength: 0.5,
      orientation: 0,
      anisotropy: 0.5,
      isSilent: false,
    );
    final lowEvents = debugFractalMusicScanScoreEvents(
      scanFrame: frame,
      zoom: 1,
      identity: identity,
      fourierFeatures: lowRegister,
      sampleRate: 8000,
      seconds: 4,
    ).where((event) => event.voice != 'percussion').toList();
    final highEvents = debugFractalMusicScanScoreEvents(
      scanFrame: frame,
      zoom: 1,
      identity: identity,
      fourierFeatures: highRegister,
      sampleRate: 8000,
      seconds: 4,
    ).where((event) => event.voice != 'percussion').toList();

    expect(highEvents, hasLength(lowEvents.length));
    for (var index = 0; index < lowEvents.length; index++) {
      final low = lowEvents[index];
      final high = highEvents[index];
      expect(high.voice, low.voice);
      expect(high.startSample, low.startSample);
      if (low.voice == 'bass') {
        expect(high.midi, low.midi, reason: 'bass remains anchored');
      } else {
        expect((high.midi - low.midi) % 12, 0, reason: low.voice);
      }
    }
  });

  test('playback background request carries Fourier controls', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    Uint8List? played;
    final service = FractalMusicService(
      isWeb: true,
      isAndroid: false,
      isLinux: false,
      webPlay: (bytes) async {
        played = Uint8List.fromList(bytes);
        return true;
      },
      webStop: () async {},
      webCancelPending: () async {},
    );
    addTearDown(service.dispose);
    final features = const FourierMusicFeatureMapper().map(
      const FourierMusicSpectrumFrame(
        lowPowerRatio: 0.58,
        midPowerRatio: 0.25,
        highPowerRatio: 0.17,
        centroid: 0.76,
        entropy: 0.68,
        flatness: 0.42,
        orientation: 1.1,
        anisotropy: 0.7,
        spectralFlux: 0.55,
      ),
    );

    await service.play(
      controller,
      scanFrame: _gradientFrame(),
      fourierFeatures: features,
    );

    expect(played, isNotNull);
    expect(played!.sublist(0, 4), <int>[82, 73, 70, 70]);
    expect(played!.length, greaterThan(44));
  });
}

FractalMusicScanFrame _gradientFrame() {
  const width = 24;
  const height = 24;
  final rgba = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final offset = (y * width + x) * 4;
      rgba[offset] = (x * 255 ~/ (width - 1));
      rgba[offset + 1] = (y * 255 ~/ (height - 1));
      rgba[offset + 2] = ((x + y) * 255 ~/ (width + height - 2));
      rgba[offset + 3] = 255;
    }
  }
  return FractalMusicScanFrame(rgba: rgba, width: width, height: height);
}

int _clippedSamples(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  var clipped = 0;
  for (var offset = 44; offset + 1 < wav.length; offset += 2) {
    final sample = data.getInt16(offset, Endian.little);
    if (sample == -32768 || sample == 32767) clipped++;
  }
  return clipped;
}
