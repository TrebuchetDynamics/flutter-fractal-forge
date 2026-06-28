import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'fractal_music_web_player_stub.dart'
    if (dart.library.html) 'fractal_music_web_player_html.dart';

typedef FractalMusicProcessStart = Future<Process> Function(
  String executable,
  List<String> arguments,
);

typedef FractalMusicTempDirFactory = Future<Directory> Function(String prefix);
typedef FractalMusicWebPlay = Future<bool> Function(Uint8List bytes);
typedef FractalMusicWebStop = Future<void> Function();

class FractalMusicService {
  static const MethodChannel _defaultAndroidChannel =
      MethodChannel('com.fractalforge/fractal_music');

  final Future<bool> Function(String command)? _commandExistsOverride;
  final FractalMusicProcessStart _startProcess;
  final FractalMusicTempDirFactory _createTempDir;
  final MethodChannel _androidChannel;
  final FractalMusicWebPlay _webPlay;
  final FractalMusicWebStop _webStop;
  final bool? _isWebOverride;
  final bool? _isAndroidOverride;
  final bool? _isLinuxOverride;
  Process? _player;
  File? _wavFile;
  bool _webPlaying = false;
  bool _androidPlaying = false;

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
  })  : _commandExistsOverride = commandExists,
        _startProcess = startProcess ??
            ((executable, arguments) => Process.start(executable, arguments)),
        _createTempDir = createTempDir ??
            ((prefix) => Directory.systemTemp.createTemp(prefix)),
        _androidChannel = androidChannel ?? _defaultAndroidChannel,
        _webPlay = webPlay ?? playFractalMusicWeb,
        _webStop = webStop ?? stopFractalMusicWeb,
        _isWebOverride = isWeb,
        _isAndroidOverride = isAndroid,
        _isLinuxOverride = isLinux;

  bool get _isWeb => _isWebOverride ?? kIsWeb;
  bool get _isAndroid => !_isWeb && (_isAndroidOverride ?? Platform.isAndroid);
  bool get _isLinux => !_isWeb && (_isLinuxOverride ?? Platform.isLinux);

  Future<void> play(FractalController controller) async {
    await stop();
    final bytes = buildFractalMusicWav(
      moduleId: controller.module.id,
      params: controller.params,
      panX: controller.view.pan.x,
      panY: controller.view.pan.y,
      zoom: controller.view.zoom,
    );
    if (_isWeb) {
      final ok = await _webPlay(bytes);
      if (!ok) {
        throw StateError(
            'Web audio playback failed; tap the music button again.');
      }
      _webPlaying = true;
      return;
    }

    if (_isAndroid) {
      final ok = await _androidChannel.invokeMethod<bool>('play', {
        'bytes': bytes,
      });
      if (ok != true) {
        throw StateError('Android audio playback failed; check audio device.');
      }
      _androidPlaying = true;
      return;
    }

    if (!_isLinux) {
      throw StateError(
          'Fractal Music playback is supported on Web, Android, and Linux.');
    }
    if (!await _commandExists('paplay') && !await _commandExists('aplay')) {
      throw StateError('No Linux audio player found (paplay or aplay).');
    }

    final dir = await _createTempDir('fractal_music_');
    final file = File('${dir.path}/loop.wav');
    await file.writeAsBytes(bytes, flush: true);
    _wavFile = file;

    // ponytail: use common Linux players, add a real audio backend only when
    // we need cross-platform playback or lower latency.
    final player = await _startProcess('sh', [
      '-c',
      'while true; do paplay "\$1" 2>/dev/null || aplay "\$1" 2>/dev/null || exit 1; done',
      'fractal-music',
      file.path,
    ]);
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

  Future<void> stop() async {
    if (_webPlaying || _isWeb) {
      await _webStop();
      _webPlaying = false;
    }
    if (_androidPlaying || _isAndroid) {
      await _androidChannel.invokeMethod<void>('stop');
      _androidPlaying = false;
    }
    _player?.kill();
    _player = null;
    await _deleteTempAudio();
  }

  void dispose() {
    if (_webPlaying || _isWeb) {
      unawaited(_webStop());
      _webPlaying = false;
    }
    if (_androidPlaying || _isAndroid) {
      unawaited(_androidChannel.invokeMethod<void>('stop'));
      _androidPlaying = false;
    }
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
  final stepSamples = sampleCount ~/ steps;
  final zoomOctave =
      (math.log(zoom.clamp(0.25, 256)) / math.ln2).round().clamp(-1, 2);

  for (var i = 0; i < sampleCount; i++) {
    final step = (i ~/ stepSamples).clamp(0, steps - 1);
    final t = (i % stepSamples) / stepSamples;
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
