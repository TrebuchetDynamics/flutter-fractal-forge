import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'fractal_music_web_player_stub.dart'
    if (dart.library.html) 'fractal_music_web_player_html.dart';

const double fractalMusicLoopSeconds = 24;
const Duration fractalMusicLoopDuration = Duration(seconds: 24);
const int _scanMusicSteps = 64;
const int _scanDistanceBins = 12;
const int _musicBeatsPerBar = 4;

/// Tempo bands, chosen so a 24-second loop holds a whole number of bars
/// (24/28/32/36/40 beats). Image detail density picks the band.
const List<int> _musicTempoBpmBands = [60, 70, 80, 90, 100];

// Band edges below are set from the fractal captures in screenshots/, where
// collapsed detail runs about 0.01-0.14 and brightness about 0.09-0.67. Even
// splits of the nominal 0-1 range leave most of each table unreachable.
// Re-measure if the scan bins or the collapse formulas change.
const List<double> _musicTempoDetailEdges = [0.03, 0.06, 0.09, 0.12];
const List<double> _musicRegisterBrightnessEdges = [0.15, 0.35];
const List<double> _musicModeBrightnessEdges = [0.22];

/// How far past an edge a feature must travel before the band it selects is
/// allowed to change. Without it, a view resting near an edge flips key, mode,
/// tempo, or register on every small pan.
const double _musicBandHysteresis = 0.04;

/// Key may only move once the hue has drifted more than this many semitones.
const double _musicRootHysteresisSemitones = 1.5;

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

/// The collapsed image features Fractal Music listens to. Cheaper to compare
/// than the raw frame, and it is what the musical decisions actually depend on.
@immutable
class FractalMusicFeatures {
  final double brightness;
  final double detail;
  final double hue;
  final double saturation;

  const FractalMusicFeatures({
    required this.brightness,
    required this.detail,
    required this.hue,
    required this.saturation,
  });

  /// Whether the image moved enough that regenerating the music is worth a
  /// restart. Hue is circular, the rest are linear.
  bool differsFrom(
    FractalMusicFeatures other, {
    double tolerance = 0.04,
  }) {
    if ((brightness - other.brightness).abs() > tolerance) return true;
    if ((detail - other.detail).abs() > tolerance) return true;
    if ((saturation - other.saturation).abs() > tolerance) return true;
    var hueDelta = (hue - other.hue).abs();
    if (hueDelta > 0.5) hueDelta = 1 - hueDelta;
    return hueDelta > tolerance;
  }
}

/// The slow-moving musical parameters. These only change once a feature has
/// travelled past a hysteresis band, so exploring an image does not restart it
/// as a different piece.
@immutable
class FractalMusicIdentity {
  final int rootSemitones;
  final bool major;
  final int registerSemitones;
  final int bpm;

  const FractalMusicIdentity({
    required this.rootSemitones,
    required this.major,
    required this.registerSemitones,
    required this.bpm,
  });

  @override
  bool operator ==(Object other) =>
      other is FractalMusicIdentity &&
      other.rootSemitones == rootSemitones &&
      other.major == major &&
      other.registerSemitones == registerSemitones &&
      other.bpm == bpm;

  @override
  int get hashCode =>
      Object.hash(rootSemitones, major, registerSemitones, bpm);
}

/// Collapses a frame to the features the composer listens to.
FractalMusicFeatures fractalMusicFeaturesOf(FractalMusicScanFrame frame) {
  if (!frame.isValid) {
    return const FractalMusicFeatures(
      brightness: 0,
      detail: 0,
      hue: 0,
      saturation: 0,
    );
  }
  final bins = <({
    double brightness,
    double detail,
    double hue,
    double saturation,
    double distance,
  })>[];
  for (var step = 0; step < _scanMusicSteps; step++) {
    bins.addAll(debugFractalMusicScanDistanceProfile(
      scanFrame: frame,
      step: step,
      steps: _scanMusicSteps,
    ));
  }
  final collapsed = _collapseDistanceProfile(bins);
  return FractalMusicFeatures(
    brightness: collapsed.brightness,
    detail: collapsed.detail,
    hue: collapsed.hue,
    saturation: collapsed.saturation,
  );
}

/// Chooses key, mode, register, and tempo, holding the previous choice until a
/// feature clears its band edge by [_musicBandHysteresis].
FractalMusicIdentity resolveFractalMusicIdentity(
  FractalMusicFeatures features, {
  FractalMusicIdentity? previous,
}) {
  final registerBand = _bandWithHysteresis(
    features.brightness,
    _musicRegisterBrightnessEdges,
    previous == null ? null : previous.registerSemitones ~/ 12,
  );
  final modeBand = _bandWithHysteresis(
    features.brightness,
    _musicModeBrightnessEdges,
    previous == null ? null : (previous.major ? 1 : 0),
  );
  final tempoBand = _bandWithHysteresis(
    features.detail,
    _musicTempoDetailEdges,
    previous == null
        ? null
        : _musicTempoBpmBands.indexOf(previous.bpm).clamp(0, _musicTempoBpmBands.length - 1),
  );

  final rawRoot = (features.hue * 12) % 12;
  var root = rawRoot.round() % 12;
  if (previous != null) {
    var drift = (rawRoot - previous.rootSemitones).abs();
    if (drift > 6) drift = 12 - drift;
    if (drift <= _musicRootHysteresisSemitones) root = previous.rootSemitones;
  }

  return FractalMusicIdentity(
    rootSemitones: root,
    major: modeBand == 1,
    registerSemitones: registerBand * 12,
    bpm: _musicTempoBpmBands[tempoBand],
  );
}

/// Picks the band [value] falls in, but refuses to leave [previousIndex] until
/// the value has cleared the edge between them by the hysteresis margin.
int _bandWithHysteresis(
  double value,
  List<double> edges,
  int? previousIndex,
) {
  var index = 0;
  while (index < edges.length && value >= edges[index]) {
    index++;
  }
  if (previousIndex == null || index == previousIndex) return index;
  final held = previousIndex.clamp(0, edges.length);
  if (index > held) {
    return value >= edges[held] + _musicBandHysteresis ? index : held;
  }
  return value < edges[held - 1] - _musicBandHysteresis ? index : held;
}

class FractalMusicService {
  static const MethodChannel _defaultAndroidChannel =
      MethodChannel('com.fractalforge/fractal_music');

  final _FractalMusicPlaybackAdapter _playback;

  /// Previous slow-moving parameters, so hysteresis survives across restarts.
  FractalMusicIdentity? _lastIdentity;

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
    if (_playback is _UnsupportedFractalMusicPlayer) {
      throw StateError(
          'Fractal Music playback is supported on Web, Android, and Linux.');
    }
    final playback = _playback;
    if (playback is _LinuxFractalMusicPlayer) {
      try {
        await playback.ensurePlayerAvailable();
      } catch (error, stackTrace) {
        try {
          await playback.stop();
        } catch (stopError) {
          throw FractalMusicStopFailure(stopError);
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
    final Uint8List bytes;
    if (scanFrame != null && scanFrame.isValid) {
      // Carry the previous identity forward so a small pan re-voices the same
      // piece instead of restarting a different one.
      final identity = resolveFractalMusicIdentity(
        fractalMusicFeaturesOf(scanFrame),
        previous: _lastIdentity,
      );
      _lastIdentity = identity;
      bytes = buildFractalMusicScanWav(
        scanFrame: scanFrame,
        zoom: controller.view.zoom,
        identity: identity,
      );
    } else {
      bytes = buildFractalMusicWav(
        moduleId: controller.module.id,
        params: controller.params,
        panX: controller.view.pan.x,
        panY: controller.view.pan.y,
        zoom: controller.view.zoom,
      );
    }
    try {
      await stop();
    } catch (error) {
      throw FractalMusicStopFailure(error);
    }
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

  Future<void> ensurePlayerAvailable() async {
    if (!await _commandExists('paplay') && !await _commandExists('aplay')) {
      throw StateError('No Linux audio player found (paplay or aplay).');
    }
  }

  @override
  Future<void> play(Uint8List bytes) async {
    final dir = await _createTempDir('fractal_music_');
    final file = File('${dir.path}/loop.wav');
    _wavFile = file;
    try {
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {
      await _deleteTempAudio();
      rethrow;
    }

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
    final int earlyExitCode;
    try {
      earlyExitCode = await player.exitCode.timeout(
        const Duration(milliseconds: 250),
        onTimeout: () => -1,
      );
    } catch (_) {
      player.kill();
      _player = null;
      await _deleteTempAudio();
      rethrow;
    }
    if (earlyExitCode != -1) {
      _player = null;
      await _deleteTempAudio();
      throw StateError('Linux audio playback failed; check audio device.');
    }
  }

  @override
  Future<void> stop() async {
    final player = _player;
    _player = null;
    Object? killError;
    StackTrace? killStackTrace;
    try {
      if (player != null && !player.kill()) {
        throw StateError('Linux audio player could not be stopped.');
      }
    } catch (error, stackTrace) {
      killError = error;
      killStackTrace = stackTrace;
    }
    await _deleteTempAudio();
    if (killError != null) {
      Error.throwWithStackTrace(killError, killStackTrace!);
    }
  }

  @override
  void dispose() {
    final player = _player;
    _player = null;
    try {
      player?.kill();
    } catch (_) {
      // Player shutdown is best-effort during synchronous disposal.
    }
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
  final notes = _visualMinorDiatonic;
  final steps = 32;
  final rootSemitones = seed % 12;
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
    final midi = 48 + zoomOctave * 12 + rootSemitones + note;
    final hz = (440 * math.pow(2, (midi - 69) / 12)).toDouble();
    final chordRoot =
        rootSemitones + _chordRootSemitones(step, steps, major: false);
    final envelope = _noteEnvelope(t, detail: scan.abs());
    final wave = _softTone(
      hz: hz,
      sample: i,
      sampleRate: sampleRate,
      harmonic: 0.18,
      harmony: 0.10 + scan.abs() * 0.08,
      droneHz: _rootHz(zoomOctave, chordRoot),
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
  FractalMusicIdentity? identity,
  int sampleRate = 22050,
  double seconds = fractalMusicLoopSeconds,
}) {
  final sampleCount = (sampleRate * seconds).round();
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
  final harmonyProfile =
      _collapseDistanceProfile(smoothedScans.expand((scan) => scan).toList());

  final resolved = identity ??
      resolveFractalMusicIdentity(FractalMusicFeatures(
        brightness: harmonyProfile.brightness,
        detail: harmonyProfile.detail,
        hue: harmonyProfile.hue,
        saturation: harmonyProfile.saturation,
      ));

  final score = _composeScanScore(
    smoothedScans: smoothedScans,
    identity: resolved,
    zoomOctave: zoomOctave,
    sampleCount: sampleCount,
    sampleRate: sampleRate,
    seconds: seconds,
  );
  return _renderScore(
    score,
    sampleCount: sampleCount,
    sampleRate: sampleRate,
  );
}

/// The four fixed ensemble voices. The image chooses how they are played, not
/// which instruments exist.
enum _MusicVoice { bass, pad, lead, texture }

class _VoiceSpec {
  final double attackSeconds;
  final double releaseSeconds;
  final double gain;
  final double harmonic;
  final double harmony;

  const _VoiceSpec({
    required this.attackSeconds,
    required this.releaseSeconds,
    required this.gain,
    required this.harmonic,
    required this.harmony,
  });
}

const Map<_MusicVoice, _VoiceSpec> _voiceSpecs = {
  _MusicVoice.bass: _VoiceSpec(
    attackSeconds: 0.05,
    releaseSeconds: 0.35,
    gain: 0.30,
    harmonic: 0.28,
    harmony: 0.02,
  ),
  _MusicVoice.pad: _VoiceSpec(
    attackSeconds: 0.25,
    releaseSeconds: 0.60,
    gain: 0.13,
    harmonic: 0.06,
    harmony: 0.10,
  ),
  _MusicVoice.lead: _VoiceSpec(
    attackSeconds: 0.02,
    releaseSeconds: 0.22,
    gain: 0.26,
    harmonic: 0.14,
    harmony: 0.05,
  ),
  _MusicVoice.texture: _VoiceSpec(
    attackSeconds: 0.005,
    releaseSeconds: 0.10,
    gain: 0.22,
    harmonic: 0.30,
    harmony: 0.02,
  ),
};

/// One scheduled note. Voices own their own envelope, so notes overlap and
/// ring past the beat that started them.
class _MusicEvent {
  final int startSample;
  final int sustainSamples;
  final int midi;
  final double velocity;

  /// Extra octave overtone, driven by image energy. Preserves the
  /// brighter-image-means-brighter-timbre mapping.
  final double harmonicBoost;
  final _MusicVoice voice;

  const _MusicEvent({
    required this.startSample,
    required this.sustainSamples,
    required this.midi,
    required this.velocity,
    required this.harmonicBoost,
    required this.voice,
  });
}

List<_MusicEvent> _composeScanScore({
  required List<
          List<
              ({
                double brightness,
                double detail,
                double hue,
                double saturation,
                double distance,
              })>>
      smoothedScans,
  required FractalMusicIdentity identity,
  required int zoomOctave,
  required int sampleCount,
  required int sampleRate,
  required double seconds,
}) {
  if (sampleCount <= 0) return const [];
  final rootSemitones = identity.rootSemitones;
  final major = identity.major;
  final scale = major ? _visualMajorDiatonic : _visualMinorDiatonic;
  // Brighter images sing higher. Octave steps only, so the chord keeps its
  // pitch classes; the bass stays anchored so the low end does not move.
  final register = identity.registerSemitones;
  final beatsPerLoop = math.max(1, (identity.bpm * seconds / 60).round());
  final steps = smoothedScans.length;
  if (steps == 0) return const [];

  // Every event must have finished releasing before the loop wraps, so the
  // last stretch of the buffer is reserved for release tails only.
  final tailSamples = math.min(
    math.max(1, sampleCount ~/ 8),
    math.max(1, (sampleRate * 0.4).round()),
  );
  final contentEnd = math.max(1, sampleCount - tailSamples);
  final samplesPerBeat = sampleCount / beatsPerLoop;

  final beats = List.generate(beatsPerLoop, (beat) {
    final start = (beat * steps) ~/ beatsPerLoop;
    final end = math.max(start + 1, ((beat + 1) * steps) ~/ beatsPerLoop);
    final bins = <({
      double brightness,
      double detail,
      double hue,
      double saturation,
      double distance,
    })>[];
    for (var step = start; step < end && step < steps; step++) {
      bins.addAll(smoothedScans[step]);
    }
    if (bins.isEmpty) {
      return (energy: 0.0, detail: 0.0, leadDistance: 0.0);
    }
    final summary = _collapseDistanceProfile(bins);
    var leadBin = bins.first;
    var leadScore = leadBin.brightness + leadBin.detail * 0.8;
    for (final candidate in bins.skip(1)) {
      final score = candidate.brightness + candidate.detail * 0.8;
      if (score > leadScore) {
        leadBin = candidate;
        leadScore = score;
      }
    }
    return (
      energy: summary.brightness,
      detail: summary.detail,
      leadDistance: leadBin.distance,
    );
  });

  final events = <_MusicEvent>[];
  final barCount = (beatsPerLoop / _musicBeatsPerBar).ceil();

  for (var bar = 0; bar < barCount; bar++) {
    final firstBeat = bar * _musicBeatsPerBar;
    final lastBeat = math.min(firstBeat + _musicBeatsPerBar, beatsPerLoop);
    if (firstBeat >= beatsPerLoop) break;

    var barEnergy = 0.0;
    var barDetail = 0.0;
    for (var beat = firstBeat; beat < lastBeat; beat++) {
      barEnergy += beats[beat].energy;
      barDetail += beats[beat].detail;
    }
    barEnergy /= lastBeat - firstBeat;
    barDetail /= lastBeat - firstBeat;
    // A bar the beam found nothing in stays silent rather than inventing a pad.
    if (barEnergy <= 0.001 && barDetail <= 0.001) continue;

    final barStart = (firstBeat * samplesPerBeat).round();
    if (barStart >= contentEnd) break;
    final barEnd = math.min((lastBeat * samplesPerBeat).round(), contentEnd);
    final barSustain = math.max(1, barEnd - barStart);
    final chordRootSemitones =
        rootSemitones + _chordRootSemitones(bar, barCount, major: major);
    final chordRootMidi = 45 + zoomOctave * 12 + chordRootSemitones;
    final barVelocity = _musicVelocity(barEnergy, barDetail);
    final harmonicBoost = barEnergy.clamp(0.0, 1.0) * 0.22;

    events.add(_MusicEvent(
      startSample: barStart,
      sustainSamples: barSustain,
      midi: chordRootMidi - 12,
      velocity: barVelocity,
      harmonicBoost: harmonicBoost * 0.5,
      voice: _MusicVoice.bass,
    ));
    for (final tone in major ? const [0, 4, 7] : const [0, 3, 7]) {
      events.add(_MusicEvent(
        startSample: barStart,
        sustainSamples: barSustain,
        midi: chordRootMidi + register + tone,
        velocity: barVelocity * 0.8,
        harmonicBoost: harmonicBoost,
        voice: _MusicVoice.pad,
      ));
    }

    for (var beat = firstBeat; beat < lastBeat; beat++) {
      final summary = beats[beat];
      if (summary.energy < 0.06) continue;
      final beatInBar = beat - firstBeat;
      // Last beat of a full bar rests, so the cadence stays audible.
      if (beatInBar == _musicBeatsPerBar - 1 &&
          lastBeat - firstBeat == _musicBeatsPerBar) {
        continue;
      }
      final beatStart = (beat * samplesPerBeat).round();
      if (beatStart >= contentEnd) break;
      final beatEnd = math.min(((beat + 1) * samplesPerBeat).round(),
          contentEnd);
      final noteSustain = math.max(1, ((beatEnd - beatStart) * 0.9).round());

      final target =
          _scanDistanceMidi(summary.leadDistance, zoomOctave, scale) +
              rootSemitones;
      // Strong beats land on chord tones; weak beats may pass through the
      // scale, which is what makes the line sound like a melody.
      final strong = beatInBar % 2 == 0;
      final leadMidi = strong
          ? _nearestChordToneMidi(
              midi: target,
              chordRootSemitones: chordRootSemitones,
              zoomOctave: zoomOctave,
              major: major,
            )
          : _nearestScaleToneMidi(
              midi: target,
              rootMidi: 45 + zoomOctave * 12 + rootSemitones,
              scale: scale,
            );

      events.add(_MusicEvent(
        startSample: beatStart,
        sustainSamples: noteSustain,
        midi: leadMidi + register,
        velocity: _musicVelocity(summary.energy, summary.detail),
        harmonicBoost: summary.energy.clamp(0.0, 1.0) * 0.14,
        voice: _MusicVoice.lead,
      ));

      if (summary.detail >= 0.08) {
        events.add(_MusicEvent(
          startSample: beatStart,
          sustainSamples: math.max(1, (samplesPerBeat * 0.25).round()),
          midi: leadMidi + 12,
          velocity: summary.detail.clamp(0.0, 1.0),
          harmonicBoost: 0.0,
          voice: _MusicVoice.texture,
        ));
      }
    }
  }

  return events;
}

/// Brightness sets the note's weight; edge density adds intensity on top, so a
/// busier image reads as busier in loudness as well as in timbre.
double _musicVelocity(double energy, double detail) => (0.18 +
        math.pow(energy.clamp(0.0, 1.0), 1.2) * 0.82 +
        detail.clamp(0.0, 1.0) * 0.35)
    .clamp(0.0, 1.15)
    .toDouble();

Uint8List _renderScore(
  List<_MusicEvent> events, {
  required int sampleCount,
  required int sampleRate,
}) {
  final left = Int16List(sampleCount);
  final right = Int16List(sampleCount);
  if (sampleCount <= 0 || events.isEmpty) {
    return _wavFromPcm16Stereo(left, right, sampleRate);
  }

  // Voices are summed into a mono bus, then panned per sample so the stereo
  // image keeps tracking the visible beam rather than the note that is playing.
  final bus = Float32List(sampleCount);
  final lastSample = sampleCount - 1;

  for (final event in events) {
    final spec = _voiceSpecs[event.voice]!;
    final attack = math.max(1, (spec.attackSeconds * sampleRate).round());
    final naturalRelease =
        math.max(1, (spec.releaseSeconds * sampleRate).round());
    final start = event.startSample.clamp(0, lastSample);
    final sustain = math.max(1, event.sustainSamples);
    // Squeeze the release rather than let a note ring past the loop point.
    final release =
        math.max(1, math.min(naturalRelease, lastSample - (start + sustain)));
    final end = math.min(lastSample, start + sustain + release);
    if (end <= start) continue;

    final hz = (440 * math.pow(2, (event.midi - 69) / 12)).toDouble();
    final gain = spec.gain * event.velocity;
    for (var i = start; i < end; i++) {
      final rel = i - start;
      final double envelope;
      if (rel < attack) {
        envelope = _smoothStep(rel / attack);
      } else if (rel >= sustain) {
        envelope = _smoothStep(1 - (rel - sustain) / release);
      } else {
        envelope = 1.0;
      }
      if (envelope <= 0) continue;
      bus[i] += _softTone(
            hz: hz,
            sample: i,
            sampleRate: sampleRate,
            harmonic: spec.harmonic + event.harmonicBoost,
            harmony: spec.harmony,
            droneHz: 0,
          ) *
          envelope *
          gain;
    }
  }

  for (var i = 0; i < sampleCount; i++) {
    final value = bus[i];
    if (value == 0) continue;
    // Gentle limiting only. A harder curve squashes bright images back toward
    // dim ones and costs the brightness-to-loudness mapping its range.
    final limited = value / (1 + value.abs() * 0.25);
    final angle = i / sampleCount * math.pi * 2 - math.pi / 2;
    final pan = math.cos(angle) * 0.72;
    left[i] = _toPcm16(limited, math.sqrt((1 - pan) * 0.5));
    right[i] = _toPcm16(limited, math.sqrt((1 + pan) * 0.5));
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
int debugFractalMusicTempoBpm(double detail) => _musicTempoBpmBands[
    _bandWithHysteresis(detail, _musicTempoDetailEdges, null)];

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
  List<int> scale = _visualMinorDiatonic,
]) {
  final noteIndex = (distance.clamp(0.0, 0.999999) * scale.length)
      .floor()
      .clamp(0, scale.length - 1);
  return 45 + zoomOctave * 12 + scale[noteIndex];
}

const List<int> _visualMajorDiatonic = [
  0,
  2,
  4,
  5,
  7,
  9,
  11,
  12,
  14,
  16,
  17,
  19,
  21,
  23,
  24,
];
const List<int> _visualMinorDiatonic = [
  0,
  2,
  3,
  5,
  7,
  8,
  10,
  12,
  14,
  15,
  17,
  19,
  20,
  22,
  24,
];

int _chordRootSemitones(int step, int steps, {required bool major}) {
  if (steps <= 0) return 0;
  final chordIndex = ((step * 4) ~/ steps).clamp(0, 3);
  const majorProgression = [0, 9, 5, 7]; // I - vi - IV - V.
  const minorProgression = [0, 8, 3, 10]; // i - VI - III - VII.
  return (major ? majorProgression : minorProgression)[chordIndex];
}

int _nearestChordToneMidi({
  required int midi,
  required int chordRootSemitones,
  required int zoomOctave,
  required bool major,
}) {
  final rootMidi = 45 + zoomOctave * 12 + chordRootSemitones;
  final chordTones = major ? const [0, 4, 7] : const [0, 3, 7];
  var closest = rootMidi;
  var closestDistance = (midi - closest).abs();
  for (var octave = -2; octave <= 2; octave++) {
    for (final tone in chordTones) {
      final candidate = rootMidi + octave * 12 + tone;
      final distance = (midi - candidate).abs();
      if (distance < closestDistance) {
        closest = candidate;
        closestDistance = distance;
      }
    }
  }
  return closest;
}

int _nearestScaleToneMidi({
  required int midi,
  required int rootMidi,
  required List<int> scale,
}) {
  var closest = rootMidi;
  var closestDistance = (midi - closest).abs();
  for (var octave = -2; octave <= 2; octave++) {
    for (final degree in scale) {
      final candidate = rootMidi + octave * 12 + degree;
      final distance = (midi - candidate).abs();
      if (distance < closestDistance) {
        closest = candidate;
        closestDistance = distance;
      }
    }
  }
  return closest;
}

double _rootHz(int zoomOctave, int rootSemitones) {
  final midi = 33 + zoomOctave * 12 + rootSemitones;
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
