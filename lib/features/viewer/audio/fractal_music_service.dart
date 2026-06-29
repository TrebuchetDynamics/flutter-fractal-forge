import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'fractal_music_web_player_stub.dart'
    if (dart.library.html) 'fractal_music_web_player_html.dart';

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
        'while true; do paplay "\$1" 2>/dev/null || aplay "\$1" 2>/dev/null || exit 1; done',
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
  double seconds = 4,
}) {
  final sampleCount = (sampleRate * seconds).round();
  final pcm = Int16List(sampleCount);
  final seed = _stableSeed(moduleId, params);
  final notes = const [0, 3, 5, 7, 10, 12, 15, 17];
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
    final hz = 440 * math.pow(2, (midi - 69) / 12);
    final envelope = math.sin(math.pi * t).clamp(0, 1);
    final wave = math.sin(2 * math.pi * hz * i / sampleRate) +
        0.35 * math.sin(2 * math.pi * hz * 2 * i / sampleRate);
    pcm[i] = (wave * envelope * 9000).round().clamp(-32768, 32767);
  }

  return _wavFromPcm16(pcm, sampleRate);
}

@visibleForTesting
Uint8List buildFractalMusicScanWav({
  required FractalMusicScanFrame scanFrame,
  required double zoom,
  int sampleRate = 22050,
  double seconds = 4,
}) {
  final sampleCount = (sampleRate * seconds).round();
  final pcm = Int16List(sampleCount);
  final notes = const [0, 3, 5, 7, 10, 12, 15, 17];
  final steps = 32;
  final zoomOctave =
      (math.log(zoom.clamp(0.25, 256)) / math.ln2).round().clamp(-1, 2);
  final scans = List.generate(
    steps,
    (step) => debugFractalMusicScanProfile(
      scanFrame: scanFrame,
      step: step,
      steps: steps,
    ),
  );

  for (var i = 0; i < sampleCount; i++) {
    final position = _musicStepPosition(i, sampleCount, steps);
    final step = position.step;
    final t = position.t;
    final scan = scans[step];
    if (scan.brightness < 0.02 && scan.detail < 0.02) {
      pcm[i] = 0;
      continue;
    }
    final noteValue =
        (scan.brightness * 0.75 + scan.detail * 0.25).clamp(0.0, 1.0);
    final note = notes[(noteValue * (notes.length - 1)).round()];
    final midi = 48 + zoomOctave * 12 + note;
    final hz = 440 * math.pow(2, (midi - 69) / 12);
    final envelope = math.sin(math.pi * t).clamp(0, 1);
    final volume =
        (0.25 + scan.brightness * 0.45 + scan.detail * 0.35).clamp(0.15, 0.95);
    final wave = math.sin(2 * math.pi * hz * i / sampleRate) +
        0.25 * math.sin(2 * math.pi * hz * 2 * i / sampleRate);
    pcm[i] = (wave * envelope * volume * 9000).round().clamp(-32768, 32767);
  }

  return _wavFromPcm16(pcm, sampleRate);
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
({double brightness, double detail}) debugFractalMusicScanProfile({
  required FractalMusicScanFrame scanFrame,
  required int step,
  int steps = 32,
}) {
  return _scanBrightnessAndDetail(
    scanFrame,
    step / steps * math.pi * 2 - math.pi / 2,
  );
}

({double brightness, double detail}) _scanBrightnessAndDetail(
  FractalMusicScanFrame frame,
  double angle,
) {
  const samples = 24;
  final cx = (frame.width - 1) / 2;
  final cy = (frame.height - 1) / 2;
  final dx = math.cos(angle);
  final dy = math.sin(angle);
  final radius = math.min(
    _distanceToEdge(center: cx, length: frame.width, direction: dx),
    _distanceToEdge(center: cy, length: frame.height, direction: dy),
  );
  var brightness = 0.0;
  var detail = 0.0;
  double? previous;

  for (var i = 0; i < samples; i++) {
    final r = radius * i / (samples - 1);
    final x = (cx + dx * r).round().clamp(0, frame.width - 1);
    final y = (cy + dy * r).round().clamp(0, frame.height - 1);
    final offset = (y * frame.width + x) * 4;
    final value = (0.2126 * frame.rgba[offset] +
            0.7152 * frame.rgba[offset + 1] +
            0.0722 * frame.rgba[offset + 2]) /
        255.0;
    brightness += value;
    final prev = previous;
    if (prev != null) detail += (value - prev).abs();
    previous = value;
  }

  return (
    brightness: (brightness / samples).clamp(0.0, 1.0),
    detail: (detail / (samples - 1) * 2).clamp(0.0, 1.0),
  );
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

Uint8List _wavFromPcm16(Int16List pcm, int sampleRate) {
  final dataBytes = pcm.length * 2;
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
  b.setUint16(22, 1, Endian.little);
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, sampleRate * 2, Endian.little);
  b.setUint16(32, 2, Endian.little);
  b.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  b.setUint32(40, dataBytes, Endian.little);
  for (var i = 0; i < pcm.length; i++) {
    b.setInt16(44 + i * 2, pcm[i], Endian.little);
  }
  return out;
}
