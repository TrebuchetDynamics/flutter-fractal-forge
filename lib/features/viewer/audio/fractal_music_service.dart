import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'fourier_music_features.dart';
import 'fractal_music_web_player_stub.dart'
    if (dart.library.html) 'fractal_music_web_player_html.dart';

part 'fractal_music_playback.dart';
part 'fractal_music_synthesis.dart';

const double fractalMusicLoopSeconds = 24;
const Duration fractalMusicLoopDuration = Duration(seconds: 24);
const int _scanMusicSteps = 64;
const int _scanDistanceBins = 12;
const int _musicBeatsPerBar = 4;

/// Tempo bands, chosen so a 24-second loop holds a whole number of bars
/// (24/28/32/36/40 beats). Image detail density picks the band.
const List<int> _musicTempoBpmBands = [60, 70, 80, 90, 100];

// Band edges are quantiles of a measured corpus of 246 renders: catalog
// thumbnails across the registry plus the app's viewer captures, each
// normalised to the grid the live scan actually sees (pixelRatio 0.25 of the
// logical viewport, ~270x480). Normalising matters -- detail is a local
// gradient measure, so reading it off a higher-resolution capture inflates it
// several fold.
//
// Corpus medians: brightness 0.57, contrast 0.11, detail 0.05, saturation 0.35.
// Quantile edges keep every band roughly equally used; even splits of 0-1 do
// not, because the features are skewed.
//
// The previous edges were fitted to a smaller, darker corpus. Once the
// attractor renders were fixed the catalog got much brighter and nearly all of
// it landed in the top register band.
//
// Re-measure if the scan bins or the collapse formulas change.
const List<double> _musicTempoDetailEdges = [0.022, 0.043, 0.079, 0.149];
const List<double> _musicRegisterBrightnessEdges = [0.39, 0.673];

/// Mode comes from contrast, not brightness. Brightness already sets the
/// register, and driving both from one feature collapsed two of the four
/// identity dimensions into one: a bright fractal was forced to be major AND
/// high, so a visually varied family sounded the same.
const List<double> _musicModeContrastEdges = [0.112];

/// Saturation picks the progression, at octiles of the measured corpus.
const List<double> _musicProgressionSaturationEdges = [
  0.171,
  0.234,
  0.303,
  0.354,
  0.411,
  0.535,
  0.632,
];

/// Progression and tempo bands are far narrower than the register/mode ones --
/// down to 0.05 and 0.015 respectively -- so they need their own margins. A
/// margin wider than the band it guards makes that band impossible to enter or
/// leave, which would strand tempo or skip progressions entirely.
const double _musicProgressionHysteresis = 0.015;
const double _musicTempoHysteresis = 0.004;

/// How far past an edge a feature must travel before the band it selects is
/// allowed to change. Without it, a view resting near an edge flips key, mode,
/// tempo, or register on every small pan.
const double _musicBandHysteresis = 0.04;

/// Key may only move once the hue has drifted more than this many semitones.
const double _musicRootHysteresisSemitones = 1.5;

/// Above this pitch the lead is doubled an octave down for body. MIDI 79 is
/// roughly 784Hz, above which a near-sine melody starts to sound thin.
const int _musicLeadDoubleMidi = 79;

/// Motion above this turns a bar's closing rest into a pickup fill.
///
/// Measured by rendering the same fractal at controlled camera offsets (pans
/// of 0.5%-50% of the visible width, zoom steps of 1.02x-2x, over three sites
/// at different depths) and taking the motion between successive frames. Of 45
/// samples only 9 moved enough to trigger a re-render at all; those 9 ran
/// 0.086-0.641 with a median of 0.203.
///
/// The threshold sits at that median so the fill actually discriminates: a
/// still view rests, a modest adjustment rests, and a substantial jump fills.
/// The earlier value of 0.08 sat below the smallest re-rendering movement, so
/// every movement filled and the rest branch was unreachable except when the
/// view was perfectly static.
const double _musicFillMotionThreshold = 0.20;

typedef FractalMusicProcessStart = Future<Process> Function(
  String executable,
  List<String> arguments,
);

typedef FractalMusicTempDirFactory = Future<Directory> Function(String prefix);
typedef FractalMusicWebPlay = Future<bool> Function(Uint8List bytes);
typedef FractalMusicWebStop = Future<void> Function();
typedef FractalMusicWebCancelPending = Future<void> Function();

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

  /// Spread of brightness across the scan, independent of its mean. Drives
  /// mode, so a bright image is no longer forced to be both major and high.
  final double contrast;
  final double detail;
  final double hue;
  final double saturation;

  const FractalMusicFeatures({
    required this.brightness,
    this.contrast = 0.0,
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
    // These dimensions use materially narrower musical bands than brightness.
    // A single 0.04 blanket threshold skipped real mode, tempo, and progression
    // changes, making pans feel delayed or unrelated to the visible image.
    if ((contrast - other.contrast).abs() > math.min(tolerance, 0.02)) {
      return true;
    }
    if ((detail - other.detail).abs() > math.min(tolerance, 0.004)) {
      return true;
    }
    if ((saturation - other.saturation).abs() >
        math.min(tolerance, _musicProgressionHysteresis)) {
      return true;
    }
    var hueDelta = (hue - other.hue).abs();
    if (hueDelta > 0.5) hueDelta = 1 - hueDelta;
    return hueDelta > tolerance;
  }

  /// How far the image travelled since [previous], as a single 0-1 scalar.
  /// Drives rhythmic fills: a still view stays sparse, a moving one gets busy.
  double motionFrom(FractalMusicFeatures previous) {
    var hueDelta = (hue - previous.hue).abs();
    if (hueDelta > 0.5) hueDelta = 1 - hueDelta;
    return ((brightness - previous.brightness).abs() +
            (detail - previous.detail).abs() +
            (saturation - previous.saturation).abs() +
            // Hue is circular, so its delta tops out at 0.5.
            hueDelta * 2)
        .clamp(0.0, 1.0);
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
  final int progressionIndex;

  const FractalMusicIdentity({
    required this.rootSemitones,
    required this.major,
    required this.registerSemitones,
    required this.bpm,
    required this.progressionIndex,
  });

  @override
  bool operator ==(Object other) =>
      other is FractalMusicIdentity &&
      other.rootSemitones == rootSemitones &&
      other.major == major &&
      other.registerSemitones == registerSemitones &&
      other.bpm == bpm &&
      other.progressionIndex == progressionIndex;

  @override
  int get hashCode => Object.hash(
        rootSemitones,
        major,
        registerSemitones,
        bpm,
        progressionIndex,
      );
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
    contrast: collapsed.contrast,
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
    features.contrast,
    _musicModeContrastEdges,
    previous == null ? null : (previous.major ? 1 : 0),
  );
  final tempoBand = _bandWithHysteresis(
    features.detail,
    _musicTempoDetailEdges,
    previous == null
        ? null
        : _musicTempoBpmBands
            .indexOf(previous.bpm)
            .clamp(0, _musicTempoBpmBands.length - 1),
    margin: _musicTempoHysteresis,
  );

  final progressionBand = _bandWithHysteresis(
    features.saturation,
    _musicProgressionSaturationEdges,
    previous?.progressionIndex,
    margin: _musicProgressionHysteresis,
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
    progressionIndex: progressionBand,
  );
}

/// Picks the band [value] falls in, but refuses to leave [previousIndex] until
/// the value has cleared the edge between them by the hysteresis margin.
int _bandWithHysteresis(
  double value,
  List<double> edges,
  int? previousIndex, {
  double margin = _musicBandHysteresis,
}) {
  var index = 0;
  while (index < edges.length && value >= edges[index]) {
    index++;
  }
  if (previousIndex == null || index == previousIndex) return index;
  final held = previousIndex.clamp(0, edges.length);
  if (index > held) {
    return value >= edges[held] + margin ? index : held;
  }
  return value < edges[held - 1] - margin ? index : held;
}

class FractalMusicService {
  static const MethodChannel _defaultAndroidChannel =
      MethodChannel('com.fractalforge/fractal_music');

  final _FractalMusicPlaybackAdapter _playback;

  /// Previous slow-moving parameters, so hysteresis survives across restarts.
  FractalMusicIdentity? _lastIdentity;

  /// Previous features, so the next render can tell how far the view moved.
  FractalMusicFeatures? _lastFeatures;
  int _operationGeneration = 0;
  bool _disposed = false;

  FractalMusicService({
    Future<bool> Function(String command)? commandExists,
    FractalMusicProcessStart? startProcess,
    FractalMusicTempDirFactory? createTempDir,
    MethodChannel? androidChannel,
    FractalMusicWebPlay? webPlay,
    FractalMusicWebStop? webStop,
    FractalMusicWebCancelPending? webCancelPending,
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
          webCancelPending: webCancelPending ?? cancelPendingFractalMusicWeb,
          isWeb: isWeb,
          isAndroid: isAndroid,
          isLinux: isLinux,
        );

  Future<void> play(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
    FourierMusicFeatures? fourierFeatures,
    double startProgress = 0,
    double Function()? startProgressProvider,
    bool Function()? shouldCommit,
    Future<void> Function()? beforeCommit,
  }) async {
    if (_disposed) return;
    if (_playback is _UnsupportedFractalMusicPlayer) {
      throw StateError(
          'Fractal Music playback is supported on Web, Android, and Linux.');
    }
    final hadPriorOperation = _operationGeneration != 0;
    final operation = ++_operationGeneration;
    bool canCommit() =>
        !_disposed &&
        operation == _operationGeneration &&
        (shouldCommit == null || shouldCommit());
    if (hadPriorOperation) {
      await _playback.cancelPending();
      if (!canCommit()) return;
    }
    try {
      final playback = _playback;
      if (playback is _LinuxFractalMusicPlayer) {
        try {
          await playback.ensurePlayerAvailable();
        } catch (error, stackTrace) {
          if (!canCommit()) return;
          try {
            await playback.stop();
          } catch (stopError) {
            throw FractalMusicStopFailure(stopError);
          }
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
      Uint8List bytes;
      FractalMusicIdentity? nextIdentity;
      FractalMusicFeatures? nextFeatures;
      if (scanFrame != null && scanFrame.isValid) {
        // Carry the previous identity forward so a small pan re-voices the same
        // piece instead of restarting a different one.
        final features = fractalMusicFeaturesOf(scanFrame);
        final identity = resolveFractalMusicIdentity(
          features,
          previous: _lastIdentity,
        );
        final previousFeatures = _lastFeatures;
        final motion = previousFeatures == null
            ? 0.0
            : features.motionFrom(previousFeatures);
        nextIdentity = identity;
        nextFeatures = features;
        bytes = await _buildFractalMusicScanWavAsync(
          scanFrame: scanFrame,
          zoom: controller.view.zoom,
          identity: identity,
          motion: motion,
          fourierFeatures: fourierFeatures,
        );
      } else {
        bytes = await _buildFractalMusicWavAsync(
          moduleId: controller.module.id,
          params: controller.params,
          panX: controller.view.pan.x,
          panY: controller.view.pan.y,
          zoom: controller.view.zoom,
        );
      }
      if (!canCommit()) return;

      // Sample only after the expensive composition. Reading the phase when the
      // rescan started made replacement audio lag behind the continuously moving
      // scanner by the complete queue + synthesis delay.
      final progress = startProgressProvider?.call() ?? startProgress;
      bytes = await _rotateFractalMusicWavAsync(bytes, progress);
      // Each adapter prepares the replacement before retiring the current loop.
      // Stopping here first created an audible hole while Android uploaded a
      // two-megabyte static buffer and while browsers decoded the new WAV.
      if (!canCommit()) return;
      await _playback.play(
        bytes,
        shouldCommit: canCommit,
        beforePublish: beforeCommit,
      );
      // Cancellation can race decoder/upload completion. Adapters prevent a
      // stale candidate from taking ownership; this guard prevents stale
      // hysteresis state from shaping the next score.
      if (!canCommit()) return;
      if (nextIdentity != null) _lastIdentity = nextIdentity;
      if (nextFeatures != null) _lastFeatures = nextFeatures;
    } catch (error, stackTrace) {
      if (!canCommit()) return;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> stop() {
    _operationGeneration++;
    return _playback.stop();
  }

  Future<void> cancelPendingPlayback() {
    _operationGeneration++;
    return _playback.cancelPending();
  }

  void dispose() {
    _disposed = true;
    _operationGeneration++;
    _playback.dispose();
  }
}
