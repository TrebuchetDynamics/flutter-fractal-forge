import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'fractal_music_web_player_stub.dart'
    if (dart.library.html) 'fractal_music_web_player_html.dart';

const double fractalMusicLoopSeconds = 8;
const Duration fractalMusicLoopDuration = Duration(seconds: 8);
const int _scanMusicSteps = 64;
const int _scanDistanceBins = 8;

typedef FractalMusicProcessStart = Future<Process> Function(
  String executable,
  List<String> arguments,
);

typedef FractalMusicTempDirFactory = Future<Directory> Function(String prefix);
typedef FractalMusicWebPlay = Future<bool> Function(Uint8List bytes);
typedef FractalMusicWebStop = Future<void> Function();

class FractalMusicStopFailure implements Exception {
  final Object error;

  const FractalMusicStopFailure(this.error);

  @override
  String toString() => 'FractalMusicStopFailure: $error';
}

class FractalMusicScanFrame {
  final Uint8List rgba;
  final int width;
  final int height;

  const FractalMusicScanFrame({
    required this.rgba,
    required this.width,
    required this.height,
  });

  bool get isValid =>
      width > 0 && height > 0 && rgba.length >= width * height * 4;

  int get visualSignature {
    if (!isValid) return 0;
    var hash = 0x811c9dc5;
    hash = (hash ^ width) * 0x01000193 & 0xffffffff;
    hash = (hash ^ height) * 0x01000193 & 0xffffffff;
    final pixelCount = width * height;
    for (var pixel = 0; pixel < pixelCount; pixel++) {
      final offset = pixel * 4;
      hash = (hash ^ rgba[offset]) * 0x01000193 & 0xffffffff;
      hash = (hash ^ rgba[offset + 1]) * 0x01000193 & 0xffffffff;
      hash = (hash ^ rgba[offset + 2]) * 0x01000193 & 0xffffffff;
    }
    return hash;
  }
}

class FractalMusicService {
  static const MethodChannel _defaultAndroidChannel =
      MethodChannel('com.fractalforge/fractal_music');

  final _FractalMusicPlaybackAdapter _playback;

  FractalMusicService({
    Future<bool> Function(String command)? commandExists,
    FractalMusicProcessStart? startProcess,
    FractalMusicTempDirFactory? createTempDir,
    MethodChannel? androidChannel,
    FractalMusicWebPlay? webPlay,
    FractalMusicWebStop? webStop,
    bool? isWeb,
    bool? isAndroid,
    bool? isLinux,
  }) : _playback = _FractalMusicPlaybackAdapter.forPlatform(
          commandExists: commandExists,
          startProcess: startProcess,
          createTempDir: createTempDir,
          androidChannel: androidChannel ?? _defaultAndroidChannel,
          webPlay: webPlay ?? playFractalMusicWeb,
          webStop: webStop ?? stopFractalMusicWeb,
          isWeb: isWeb,
          isAndroid: isAndroid,
          isLinux: isLinux,
        );

  Future<void> play(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) async {
    try {
      await stop();
    } catch (error) {
      throw FractalMusicStopFailure(error);
    }
    final bytes = scanFrame != null && scanFrame.isValid
        ? buildFractalMusicScanWav(
            scanFrame: scanFrame,
            zoom: controller.view.zoom,
          )
        : buildFractalMusicWav(
            moduleId: controller.module.id,
            params: controller.params,
            panX: controller.view.pan.x,
            panY: controller.view.pan.y,
            zoom: controller.view.zoom,
          );
    await _playback.play(bytes);
  }

  Future<void> stop() => _playback.stop();

  void dispose() => _playback.dispose();
}

abstract class _FractalMusicPlaybackAdapter {
  const _FractalMusicPlaybackAdapter();

  Future<void> play(Uint8List bytes);
  Future<void> stop();

  void dispose() {
    unawaited(stop());
  }

  factory _FractalMusicPlaybackAdapter.forPlatform({
    required Future<bool> Function(String command)? commandExists,
    required FractalMusicProcessStart? startProcess,
    required FractalMusicTempDirFactory? createTempDir,
    required MethodChannel androidChannel,
    required FractalMusicWebPlay webPlay,
    required FractalMusicWebStop webStop,
    required bool? isWeb,
    required bool? isAndroid,
    required bool? isLinux,
  }) {
    final web = isWeb ?? kIsWeb;
    if (web) return _WebFractalMusicPlayer(webPlay, webStop);

    final android = isAndroid ?? Platform.isAndroid;
    if (android) return _AndroidFractalMusicPlayer(androidChannel);

    final linux = isLinux ?? Platform.isLinux;
    if (linux) {
      return _LinuxFractalMusicPlayer(
        commandExists: commandExists,
        startProcess: startProcess,
        createTempDir: createTempDir,
      );
    }

    return _UnsupportedFractalMusicPlayer();
  }
}

class _WebFractalMusicPlayer extends _FractalMusicPlaybackAdapter {
  final FractalMusicWebPlay _play;
  final FractalMusicWebStop _stop;
  bool _playing = false;

  _WebFractalMusicPlayer(this._play, this._stop);

  @override
  Future<void> play(Uint8List bytes) async {
    final ok = await _play(bytes);
    if (!ok) {
      throw StateError(
          'Web audio playback failed; tap the music button again.');
    }
    _playing = true;
  }

  @override
  Future<void> stop() async {
    if (!_playing) {
      await _stop();
      return;
    }
    _playing = false;
    await _stop();
  }
}

class _AndroidFractalMusicPlayer extends _FractalMusicPlaybackAdapter {
  final MethodChannel _channel;
  bool _playing = false;

  _AndroidFractalMusicPlayer(this._channel);

  @override
  Future<void> play(Uint8List bytes) async {
    final ok = await _channel.invokeMethod<bool>('play', {'bytes': bytes});
    if (ok != true) {
      throw StateError('Android audio playback failed; check audio device.');
    }
    _playing = true;
  }

  @override
  Future<void> stop() async {
    if (!_playing) {
      await _channel.invokeMethod<void>('stop');
      return;
    }
    _playing = false;
    await _channel.invokeMethod<void>('stop');
  }
}

class _LinuxFractalMusicPlayer implements _FractalMusicPlaybackAdapter {
  final Future<bool> Function(String command)? _commandExistsOverride;
  final FractalMusicProcessStart _startProcess;
  final FractalMusicTempDirFactory _createTempDir;
  Process? _player;
  File? _wavFile;

  _LinuxFractalMusicPlayer({
    required Future<bool> Function(String command)? commandExists,
    required FractalMusicProcessStart? startProcess,
    required FractalMusicTempDirFactory? createTempDir,
  })  : _commandExistsOverride = commandExists,
        _startProcess = startProcess ??
            ((executable, arguments) => Process.start(executable, arguments)),
        _createTempDir = createTempDir ??
            ((prefix) => Directory.systemTemp.createTemp(prefix));

  @override
  Future<void> play(Uint8List bytes) async {
    if (!await _commandExists('paplay') && !await _commandExists('aplay')) {
      throw StateError('No Linux audio player found (paplay or aplay).');
    }

    final dir = await _createTempDir('fractal_music_');
    final file = File('${dir.path}/loop.wav');
    await file.writeAsBytes(bytes, flush: true);
    _wavFile = file;

    // ponytail: use common Linux players, add a real audio backend only when
    // we need cross-platform playback or lower latency.
    final Process player;
    try {
      player = await _startProcess('sh', [
        '-c',
        'child=; cleanup() { status=\$?; [ -n "\$child" ] && kill "\$child" 2>/dev/null; exit "\$status"; }; trap cleanup TERM INT EXIT; while true; do (paplay "\$1" 2>/dev/null || aplay "\$1" 2>/dev/null) & child=\$!; wait "\$child" || exit 1; child=; done',
        'fractal-music',
        file.path,
      ]);
    } catch (_) {
      await _deleteTempAudio();
      rethrow;
    }
    _player = player;
    final earlyExitCode = await player.exitCode.timeout(
      const Duration(milliseconds: 250),
      onTimeout: () => -1,
    );
    if (earlyExitCode != -1) {
      _player = null;
      await _deleteTempAudio();
      throw StateError('Linux audio playback failed; check audio device.');
    }
  }

  @override
  Future<void> stop() async {
    _player?.kill();
    _player = null;
    await _deleteTempAudio();
  }

  @override
  void dispose() {
    _player?.kill();
    _player = null;
    try {
      final file = _wavFile;
      if (file != null) {
        final parent = file.parent;
        if (parent.existsSync()) parent.deleteSync(recursive: true);
      }
    } catch (_) {
      // Temp cleanup best-effort only.
    }
    _wavFile = null;
  }

  Future<void> _deleteTempAudio() async {
    try {
      final file = _wavFile;
      if (file != null) {
        final parent = file.parent;
        if (await parent.exists()) await parent.delete(recursive: true);
      }
    } catch (_) {
      // Temp cleanup best-effort only.
    }
    _wavFile = null;
  }

  Future<bool> _commandExists(String command) async {
    final override = _commandExistsOverride;
    if (override != null) return override(command);

    final result = await Process.run('sh', [
      '-c',
      'command -v "$command" >/dev/null 2>&1',
    ]);
    return result.exitCode == 0;
  }
}

class _UnsupportedFractalMusicPlayer extends _FractalMusicPlaybackAdapter {
  @override
  Future<void> play(Uint8List bytes) async {
    throw StateError(
        'Fractal Music playback is supported on Web, Android, and Linux.');
  }

  @override
  Future<void> stop() async {}
}

@visibleForTesting
Uint8List buildFractalMusicWav({
  required String moduleId,
  required Map<String, Object> params,
  required double panX,
  required double panY,
  required double zoom,
  int sampleRate = 22050,
  double seconds = fractalMusicLoopSeconds,
}) {
  final sampleCount = (sampleRate * seconds).round();
  final left = Int16List(sampleCount);
  final right = Int16List(sampleCount);
  final seed = _stableSeed(moduleId, params);
  final notes = _visualMinorPentatonic;
  final steps = 16;
  final zoomOctave =
      (math.log(zoom.clamp(0.25, 256)) / math.ln2).round().clamp(-1, 2);

  for (var i = 0; i < sampleCount; i++) {
    final position = _musicStepPosition(i, sampleCount, steps);
    final step = position.step;
    final t = position.t;
    final radius = (step + 1) / steps;
    final angle = step * math.pi * (3 - math.sqrt(5));
    final scan = math.sin(
      seed * 0.0001 +
          (panX + radius * math.cos(angle)) * 4.7 +
          (panY + radius * math.sin(angle)) * 5.3 +
          math.log(zoom.clamp(1e-6, 1e6)) * 0.31,
    );
    final note = notes[((scan + 1) * 0.5 * (notes.length - 1)).round()];
    final midi = 48 + zoomOctave * 12 + note;
    final hz = (440 * math.pow(2, (midi - 69) / 12)).toDouble();
    final envelope = _noteEnvelope(t, detail: scan.abs());
    final wave = _softTone(
      hz: hz,
      sample: i,
      sampleRate: sampleRate,
      harmonic: 0.18,
      harmony: 0.10 + scan.abs() * 0.08,
      droneHz: hz / 2,
    );
    final pan = math.sin(
          angle +
              panX * 0.7 +
              panY * 0.5 +
              math.log(zoom.clamp(1e-6, 1e6)) * 0.11,
        ) *
        0.45;
    final leftGain = math.sqrt((1 - pan) * 0.5);
    final rightGain = math.sqrt((1 + pan) * 0.5);
    left[i] = _toPcm16(wave, envelope * 0.52 * leftGain);
    right[i] = _toPcm16(wave, envelope * 0.52 * rightGain);
  }

  return _wavFromPcm16Stereo(left, right, sampleRate);
}

@visibleForTesting
Uint8List buildFractalMusicScanWav({
  required FractalMusicScanFrame scanFrame,
  required double zoom,
  int sampleRate = 22050,
  double seconds = fractalMusicLoopSeconds,
}) {
  final sampleCount = (sampleRate * seconds).round();
  final left = Int16List(sampleCount);
  final right = Int16List(sampleCount);
  const steps = _scanMusicSteps;
  final zoomOctave =
      (math.log(zoom.clamp(0.25, 256)) / math.ln2).round().clamp(-1, 2);
  final scans = List.generate(
    steps,
    (step) => debugFractalMusicScanDistanceProfile(
      scanFrame: scanFrame,
      step: step,
      steps: steps,
    ),
  );
  final smoothedScans = List.generate(
    steps,
    (step) => _smoothedScanDistanceProfile(scans, step),
  );

  for (var i = 0; i < sampleCount; i++) {
    final position = _musicStepPosition(i, sampleCount, steps);
    final step = position.step;
    final t = position.t;
    final bins = smoothedScans[step];
    final activeBins = bins
        .where((bin) => bin.brightness >= 0.02 || bin.detail >= 0.02)
        .length;
    if (activeBins == 0) continue;

    final maxDetail = bins.fold<double>(0, (maxDetail, bin) {
      return math.max(maxDetail, bin.detail);
    });
    final profile = _collapseDistanceProfile(bins);
    final rootSemitones = (profile.hue * 12).round() % 12;
    final scale = profile.brightness >= 0.5
        ? _visualMajorPentatonic
        : _visualMinorPentatonic;
    final envelope = _noteEnvelope(t, detail: maxDetail);
    final angle = step / steps * math.pi * 2 - math.pi / 2;
    final pan = math.cos(angle) * 0.72;
    final leftGain = math.sqrt((1 - pan) * 0.5);
    final rightGain = math.sqrt((1 + pan) * 0.5);
    final mixScale = math.sqrt(activeBins);
    var mix = 0.0;

    for (final bin in bins) {
      if (bin.brightness < 0.02 && bin.detail < 0.02) continue;
      final midi =
          _scanDistanceMidi(bin.distance, zoomOctave, scale) + rootSemitones;
      final hz = (440 * math.pow(2, (midi - 69) / 12)).toDouble();
      final gain = (math.pow(bin.brightness, 1.15) * 0.56 + bin.detail * 0.16)
              .clamp(0.0, 0.68) /
          mixScale;
      mix += _softTone(
            hz: hz,
            sample: i,
            sampleRate: sampleRate,
            harmonic: 0.04 + bin.saturation * 0.10,
            harmony: 0.04 + bin.detail * 0.10,
            droneHz: _rootHz(zoomOctave),
          ) *
          gain;
    }

    left[i] = _toPcm16(mix, envelope * leftGain);
    right[i] = _toPcm16(mix, envelope * rightGain);
  }

  return _wavFromPcm16Stereo(left, right, sampleRate);
}

({int step, double t}) _musicStepPosition(
    int sample, int sampleCount, int steps) {
  if (sampleCount <= 0) return (step: 0, t: 0.5);
  final step = ((sample * steps) ~/ sampleCount).clamp(0, steps - 1);
  final start = (step * sampleCount / steps).floor();
  final end = math.max(start + 1, ((step + 1) * sampleCount / steps).floor());
  final span = end - start;
  final t = span <= 2 ? 0.5 : (sample - start) / (span - 1);
  return (step: step, t: t.clamp(0.0, 1.0));
}

@visibleForTesting
({double brightness, double detail, double hue, double saturation})
    debugFractalMusicScanProfile({
  required FractalMusicScanFrame scanFrame,
  required int step,
  int steps = _scanMusicSteps,
}) {
  return _collapseDistanceProfile(
    debugFractalMusicScanDistanceProfile(
      scanFrame: scanFrame,
      step: step,
      steps: steps,
    ),
  );
}

@visibleForTesting
List<
    ({
      double brightness,
      double detail,
      double hue,
      double saturation,
      double distance,
    })> debugFractalMusicScanDistanceProfile({
  required FractalMusicScanFrame scanFrame,
  required int step,
  int steps = _scanMusicSteps,
}) {
  return _scanDistanceProfile(
    scanFrame,
    step / steps * math.pi * 2 - math.pi / 2,
  );
}

@visibleForTesting
int debugFractalMusicDistanceMidi({
  required double distance,
  required double zoom,
}) {
  final zoomOctave =
      (math.log(zoom.clamp(0.25, 256)) / math.ln2).round().clamp(-1, 2);
  return _scanDistanceMidi(distance, zoomOctave);
}

List<
    ({
      double brightness,
      double detail,
      double hue,
      double saturation,
      double distance,
    })> _smoothedScanDistanceProfile(
  List<
          List<
              ({
                double brightness,
                double detail,
                double hue,
                double saturation,
                double distance,
              })>>
      scans,
  int step,
) {
  if (scans.isEmpty) return const [];
  final prev = scans[(step - 1) % scans.length];
  final current = scans[step % scans.length];
  final next = scans[(step + 1) % scans.length];
  const sideWeight = 0.18;
  const centerWeight = 1 - sideWeight * 2;
  double blend(double a, double b, double c) =>
      a * sideWeight + b * centerWeight + c * sideWeight;

  return List.generate(current.length, (i) {
    final a = prev[i];
    final b = current[i];
    final c = next[i];
    final hueX = math.cos(a.hue * math.pi * 2) * sideWeight +
        math.cos(b.hue * math.pi * 2) * centerWeight +
        math.cos(c.hue * math.pi * 2) * sideWeight;
    final hueY = math.sin(a.hue * math.pi * 2) * sideWeight +
        math.sin(b.hue * math.pi * 2) * centerWeight +
        math.sin(c.hue * math.pi * 2) * sideWeight;
    var hue = math.atan2(hueY, hueX) / (math.pi * 2);
    if (hue < 0) hue += 1;
    return (
      brightness:
          blend(a.brightness, b.brightness, c.brightness).clamp(0.0, 1.0),
      detail: blend(a.detail, b.detail, c.detail).clamp(0.0, 1.0),
      hue: hue.clamp(0.0, 1.0),
      saturation:
          blend(a.saturation, b.saturation, c.saturation).clamp(0.0, 1.0),
      distance: b.distance,
    );
  });
}

({double brightness, double detail, double hue, double saturation})
    _collapseDistanceProfile(
  List<
          ({
            double brightness,
            double detail,
            double hue,
            double saturation,
            double distance,
          })>
      bins,
) {
  if (bins.isEmpty) return (brightness: 0, detail: 0, hue: 0, saturation: 0);
  var brightness = 0.0;
  var detail = 0.0;
  var saturation = 0.0;
  var hueX = 0.0;
  var hueY = 0.0;
  var hueWeight = 0.0;
  for (final bin in bins) {
    brightness += bin.brightness;
    detail += bin.detail;
    saturation += bin.saturation;
    final weight = bin.brightness + bin.saturation * 0.25;
    hueX += math.cos(bin.hue * math.pi * 2) * weight;
    hueY += math.sin(bin.hue * math.pi * 2) * weight;
    hueWeight += weight;
  }
  var hue = hueWeight <= 1e-9 ? 0.0 : math.atan2(hueY, hueX) / (math.pi * 2);
  if (hue < 0) hue += 1;
  return (
    brightness: (brightness / bins.length).clamp(0.0, 1.0),
    detail: (detail / bins.length).clamp(0.0, 1.0),
    hue: hue.clamp(0.0, 1.0),
    saturation: (saturation / bins.length).clamp(0.0, 1.0),
  );
}

List<
    ({
      double brightness,
      double detail,
      double hue,
      double saturation,
      double distance,
    })> _scanDistanceProfile(
  FractalMusicScanFrame frame,
  double angle,
) {
  if (!frame.isValid) return const [];
  const samplesPerBin = 4;
  final cx = (frame.width - 1) / 2;
  final cy = (frame.height - 1) / 2;
  final dx = math.cos(angle);
  final dy = math.sin(angle);
  final radius = math.min(
    _distanceToEdge(center: cx, length: frame.width, direction: dx),
    _distanceToEdge(center: cy, length: frame.height, direction: dy),
  );

  return List.generate(_scanDistanceBins, (bin) {
    var brightness = 0.0;
    var detail = 0.0;
    var red = 0.0;
    var green = 0.0;
    var blue = 0.0;
    var alpha = 0.0;
    double? previous;

    for (var sample = 0; sample < samplesPerBin; sample++) {
      final fraction =
          (bin + (sample + 0.5) / samplesPerBin) / _scanDistanceBins;
      final radial = radius * fraction;
      final x = (cx + dx * radial).round().clamp(0, frame.width - 1);
      final y = (cy + dy * radial).round().clamp(0, frame.height - 1);
      final offset = (y * frame.width + x) * 4;
      final a = frame.rgba[offset + 3] / 255.0;
      final r = frame.rgba[offset] / 255.0 * a;
      final g = frame.rgba[offset + 1] / 255.0 * a;
      final b = frame.rgba[offset + 2] / 255.0 * a;
      final value = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      brightness += value;
      red += r;
      green += g;
      blue += b;
      alpha += a;
      final last = previous;
      if (last != null) detail += (value - last).abs();
      previous = value;
    }

    final colorScale = alpha <= 1e-9 ? 0.0 : 1 / alpha;
    final avgR = red * colorScale;
    final avgG = green * colorScale;
    final avgB = blue * colorScale;
    final maxChannel = math.max(avgR, math.max(avgG, avgB));
    final minChannel = math.min(avgR, math.min(avgG, avgB));
    return (
      brightness: (brightness / samplesPerBin).clamp(0.0, 1.0),
      detail: (detail / (samplesPerBin - 1) * 2).clamp(0.0, 1.0),
      hue: _rgbHue(avgR, avgG, avgB),
      saturation: maxChannel <= 1e-9
          ? 0.0
          : ((maxChannel - minChannel) / maxChannel).clamp(0.0, 1.0),
      distance: (bin + 0.5) / _scanDistanceBins,
    );
  });
}

int _scanDistanceMidi(
  double distance,
  int zoomOctave, [
  List<int> scale = _visualMinorPentatonic,
]) {
  final noteIndex = (distance.clamp(0.0, 0.999999) * scale.length)
      .floor()
      .clamp(0, scale.length - 1);
  return 45 + zoomOctave * 12 + scale[noteIndex];
}

const List<int> _visualMajorPentatonic = [0, 2, 4, 7, 9, 12, 14, 16];
const List<int> _visualMinorPentatonic = [0, 2, 3, 5, 7, 10, 12, 15];

double _rootHz(int zoomOctave) {
  final midi = 33 + zoomOctave * 12;
  return (440 * math.pow(2, (midi - 69) / 12)).toDouble();
}

double _noteEnvelope(double t, {required double detail}) {
  final attack = (0.16 - detail * 0.08).clamp(0.06, 0.16);
  final release = 0.24;
  if (t < attack) return _smoothStep(t / attack);
  if (t > 1 - release) return _smoothStep((1 - t) / release);
  return 1.0;
}

double _smoothStep(double t) {
  final x = t.clamp(0.0, 1.0);
  return x * x * (3 - 2 * x);
}

double _softTone({
  required double hz,
  required int sample,
  required int sampleRate,
  required double harmonic,
  required double harmony,
  required double droneHz,
}) {
  final time = sample / sampleRate;
  final fundamental = math.sin(2 * math.pi * hz * time);
  final overtone = math.sin(2 * math.pi * hz * 2 * time) * harmonic;
  final fifth = math.sin(2 * math.pi * hz * 1.5 * time) * harmony;
  final drone = math.sin(2 * math.pi * droneHz * time) * 0.16;
  final mixed = (fundamental * 0.66 + overtone + fifth + drone) * 0.88;
  return mixed / (1 + mixed.abs());
}

int _toPcm16(double wave, double gain) {
  return (wave * gain * 10000).round().clamp(-32768, 32767).toInt();
}

double _rgbHue(double r, double g, double b) {
  final maxChannel = math.max(r, math.max(g, b));
  final minChannel = math.min(r, math.min(g, b));
  final delta = maxChannel - minChannel;
  if (delta <= 1e-9) return 0.0;
  double hue;
  if (maxChannel == r) {
    hue = ((g - b) / delta) % 6;
  } else if (maxChannel == g) {
    hue = (b - r) / delta + 2;
  } else {
    hue = (r - g) / delta + 4;
  }
  return ((hue * 60) % 360) / 360;
}

double _distanceToEdge({
  required double center,
  required int length,
  required double direction,
}) {
  if (direction > 1e-9) return (length - 1 - center) / direction;
  if (direction < -1e-9) return -center / direction;
  return double.infinity;
}

int _stableSeed(String moduleId, Map<String, Object> params) {
  var hash = 0x811c9dc5;
  for (final codeUnit in moduleId.codeUnits) {
    hash = (hash ^ codeUnit) * 0x01000193 & 0xffffffff;
  }
  for (final key in params.keys.toList()..sort()) {
    final value = params[key];
    for (final codeUnit in '$key=$value'.codeUnits) {
      hash = (hash ^ codeUnit) * 0x01000193 & 0xffffffff;
    }
  }
  return hash;
}

Uint8List _wavFromPcm16Stereo(
  Int16List left,
  Int16List right,
  int sampleRate,
) {
  assert(left.length == right.length);
  final out = _wavHeader(
    frameCount: left.length,
    sampleRate: sampleRate,
    channels: 2,
  );
  final b = ByteData.sublistView(out);
  for (var i = 0; i < left.length; i++) {
    final offset = 44 + i * 4;
    b.setInt16(offset, left[i], Endian.little);
    b.setInt16(offset + 2, right[i], Endian.little);
  }
  return out;
}

Uint8List _wavHeader({
  required int frameCount,
  required int sampleRate,
  required int channels,
}) {
  final dataBytes = frameCount * channels * 2;
  final out = Uint8List(44 + dataBytes);
  final b = ByteData.sublistView(out);
  void ascii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      out[offset + i] = value.codeUnitAt(i);
    }
  }

  ascii(0, 'RIFF');
  b.setUint32(4, 36 + dataBytes, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little);
  b.setUint16(22, channels, Endian.little);
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, sampleRate * channels * 2, Endian.little);
  b.setUint16(32, channels * 2, Endian.little);
  b.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  b.setUint32(40, dataBytes, Endian.little);
  return out;
}
