part of 'fractal_music_service.dart';

Future<Uint8List> _buildFractalMusicWavAsync({
  required String moduleId,
  required Map<String, Object> params,
  required double panX,
  required double panY,
  required double zoom,
}) =>
    compute(_buildFractalMusicWavInBackground, <String, Object>{
      'moduleId': moduleId,
      'params': params,
      'panX': panX,
      'panY': panY,
      'zoom': zoom,
    });

Uint8List _buildFractalMusicWavInBackground(Map<String, Object> request) =>
    buildFractalMusicWav(
      moduleId: request['moduleId']! as String,
      params: (request['params']! as Map).cast<String, Object>(),
      panX: request['panX']! as double,
      panY: request['panY']! as double,
      zoom: request['zoom']! as double,
    );

Future<Uint8List> _buildFractalMusicScanWavAsync({
  required FractalMusicScanFrame scanFrame,
  required double zoom,
  required FractalMusicIdentity identity,
  required double motion,
  FourierMusicFeatures? fourierFeatures,
}) {
  final request = <String, Object>{
    'rgba': scanFrame.rgba,
    'width': scanFrame.width,
    'height': scanFrame.height,
    'zoom': zoom,
    'rootSemitones': identity.rootSemitones,
    'major': identity.major,
    'registerSemitones': identity.registerSemitones,
    'bpm': identity.bpm,
    'progressionIndex': identity.progressionIndex,
    'motion': motion,
  };
  if (fourierFeatures != null && !fourierFeatures.isSilent) {
    request['fourierFeatures'] = <double>[
      fourierFeatures.bassWeight,
      fourierFeatures.padOpenness,
      fourierFeatures.highTexture,
      fourierFeatures.leadRegister,
      fourierFeatures.rhythmicComplexity,
      fourierFeatures.stereoBias,
      fourierFeatures.transitionStrength,
      fourierFeatures.orientation,
      fourierFeatures.anisotropy,
    ];
  }
  return compute(_buildFractalMusicScanWavInBackground, request);
}

Uint8List _buildFractalMusicScanWavInBackground(Map<String, Object> request) =>
    buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: request['rgba']! as Uint8List,
        width: request['width']! as int,
        height: request['height']! as int,
      ),
      zoom: request['zoom']! as double,
      identity: FractalMusicIdentity(
        rootSemitones: request['rootSemitones']! as int,
        major: request['major']! as bool,
        registerSemitones: request['registerSemitones']! as int,
        bpm: request['bpm']! as int,
        progressionIndex: request['progressionIndex']! as int,
      ),
      motion: request['motion']! as double,
      fourierFeatures: switch (request['fourierFeatures']) {
        final List<Object?> values => FourierMusicFeatures(
            bassWeight: values[0]! as double,
            padOpenness: values[1]! as double,
            highTexture: values[2]! as double,
            leadRegister: values[3]! as double,
            rhythmicComplexity: values[4]! as double,
            stereoBias: values[5]! as double,
            transitionStrength: values[6]! as double,
            orientation: values[7]! as double,
            anisotropy: values[8]! as double,
            isSilent: false,
          ),
        _ => null,
      },
    );

Future<Uint8List> _rotateFractalMusicWavAsync(
  Uint8List wav,
  double startProgress,
) =>
    compute(_rotateFractalMusicWavInBackground, <String, Object>{
      'wav': wav,
      'startProgress': startProgress,
    });

Uint8List _rotateFractalMusicWavInBackground(Map<String, Object> request) =>
    _rotateFractalMusicWav(
      request['wav']! as Uint8List,
      request['startProgress']! as double,
    );

Uint8List _rotateFractalMusicWav(Uint8List wav, double startProgress) {
  final progress = startProgress.isFinite ? startProgress % 1.0 : 0.0;
  if (progress == 0 || wav.length <= 44) return wav;
  final header = ByteData.sublistView(wav);
  final channels = header.getUint16(22, Endian.little);
  final bitsPerSample = header.getUint16(34, Endian.little);
  final dataBytes = header.getUint32(40, Endian.little);
  final bytesPerFrame = channels * bitsPerSample ~/ 8;
  if (bytesPerFrame <= 0 || dataBytes <= 0 || 44 + dataBytes > wav.length) {
    return wav;
  }
  final frameCount = dataBytes ~/ bytesPerFrame;
  final startFrame = (progress * frameCount).round() % frameCount;
  if (startFrame == 0) return wav;
  final split = 44 + startFrame * bytesPerFrame;
  final out = Uint8List(wav.length);
  out.setRange(0, 44, wav);
  final tailBytes = 44 + dataBytes - split;
  out.setRange(44, 44 + tailBytes, wav, split);
  out.setRange(44 + tailBytes, 44 + dataBytes, wav, 44);
  return out;
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
    final chordRoot = rootSemitones +
        _chordRootSemitones(step, steps, _musicMinorProgressions[0]);
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
    left[i] = _toPcm16(wave, envelope * 0.52 * leftGain * _musicMasterGain);
    right[i] = _toPcm16(wave, envelope * 0.52 * rightGain * _musicMasterGain);
  }

  return _wavFromPcm16Stereo(left, right, sampleRate);
}

Uint8List buildFractalMusicScanWav({
  required FractalMusicScanFrame scanFrame,
  required double zoom,
  FractalMusicIdentity? identity,
  FourierMusicFeatures? fourierFeatures,
  double motion = 0,
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
        contrast: harmonyProfile.contrast,
        detail: harmonyProfile.detail,
        hue: harmonyProfile.hue,
        saturation: harmonyProfile.saturation,
      ));

  final score = _composeScanScore(
    smoothedScans: smoothedScans,
    identity: resolved,
    motion: motion,
    zoomOctave: zoomOctave,
    sampleCount: sampleCount,
    sampleRate: sampleRate,
    seconds: seconds,
    fourierFeatures: fourierFeatures,
  );
  return _renderScore(
    score,
    sampleCount: sampleCount,
    sampleRate: sampleRate,
    stereoBias: fourierFeatures?.stereoBias ?? 0,
  );
}

/// Five fixed ensemble sections: electric/upright-style bass, warm strings,
/// melodic lead, restrained high texture, and a compact drum kit. Rendered
/// image features decide how each section plays.
enum _MusicVoice { bass, pad, lead, texture, percussion }

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

// Lift both score and fallback playback to an audible level. The score applies
// this before its final soft limiter so PCM conversion never becomes the
// limiter; the fallback oscillator is already mathematically bounded.
const double _musicMasterGain = 3.0;
const double _musicMasterLimiterStrength = 0.35;

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
    gain: 0.16,
    harmonic: 0.30,
    harmony: 0.02,
  ),
  _MusicVoice.percussion: _VoiceSpec(
    attackSeconds: 0.001,
    releaseSeconds: 0.18,
    gain: 0.22,
    harmonic: 0,
    harmony: 0,
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
  required double motion,
  required int zoomOctave,
  required int sampleCount,
  required int sampleRate,
  required double seconds,
  FourierMusicFeatures? fourierFeatures,
}) {
  if (sampleCount <= 0) return const [];
  final rootSemitones = identity.rootSemitones;
  final major = identity.major;
  final scale = major ? _visualMajorDiatonic : _visualMinorDiatonic;
  // Brighter images sing higher. Octave steps only, so the chord keeps its
  // pitch classes; the bass stays anchored so the low end does not move.
  final register = identity.registerSemitones +
      (fourierFeatures == null
          ? 0
          : ((fourierFeatures.leadRegister - 0.5) * 2).round() * 12);
  final bassScale =
      fourierFeatures == null ? 1.0 : 0.7 + fourierFeatures.bassWeight * 0.6;
  final padScale =
      fourierFeatures == null ? 1.0 : 0.7 + fourierFeatures.padOpenness * 0.6;
  final textureScale =
      fourierFeatures == null ? 1.0 : 0.55 + fourierFeatures.highTexture * 0.9;
  final rhythmComplexity = fourierFeatures?.rhythmicComplexity ?? 0.5;
  final effectiveMotion = math.max(
    motion,
    (fourierFeatures?.transitionStrength ?? 0) * 0.4,
  );
  // The pad is the bridge between the anchored bass and the melody, so it only
  // follows the register lift as far as one octave. Letting it take the full
  // two leaves a hole in the middle of the spectrum: measured on a bright
  // fractal, 90-180Hz and 1440-2880Hz both carried heavy energy while
  // 360-720Hz sat at 2%, so the arrangement split into bass plus treble with
  // nothing between.
  final padRegister = math.min(register, 12);
  final progression = _musicProgression(
    major: major,
    index: identity.progressionIndex,
  );
  final samplesPerBeat = sampleRate * 60 / identity.bpm;
  // Preserve the selected tempo for arbitrary export lengths. Rounding a beat
  // count and then stretching it across the whole buffer changes 80 BPM into
  // 60 BPM for a one-second export. Generate the natural onset grid and clip
  // events at the content boundary instead.
  final beatsPerLoop = math.max(1, (sampleCount / samplesPerBeat).ceil());
  final steps = smoothedScans.length;
  if (steps == 0) return const [];

  // Every event must have finished releasing before the loop wraps, so the
  // last stretch of the buffer is reserved for release tails only.
  final tailSamples = math.min(
    math.max(1, sampleCount ~/ 8),
    math.max(1, (sampleRate * 0.4).round()),
  );
  final contentEnd = math.max(1, sampleCount - tailSamples);

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

  // A frame the beam found nothing in produces no music at all. A dark bar
  // inside a live image is different: it keeps its pad and bass so the piece
  // holds together, and only loses the lead. Fractals are mostly dark, so
  // dropping whole bars leaves the iconic shapes sounding broken, not sparse.
  var frameEnergy = 0.0;
  var frameDetail = 0.0;
  for (final beat in beats) {
    frameEnergy += beat.energy;
    frameDetail += beat.detail;
  }
  frameEnergy /= beats.length;
  frameDetail /= beats.length;
  if (frameEnergy <= 0.001 && frameDetail <= 0.001) return const [];

  final events = <_MusicEvent>[];
  int? firstLeadMidi;
  int? previousLeadMidi;
  final barCount = (beatsPerLoop / _musicBeatsPerBar).ceil();

  int? previousBassMidi;

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
    final barIsDark = barEnergy <= 0.001 && barDetail <= 0.001;

    final barStart = (firstBeat * samplesPerBeat).round();
    if (barStart >= contentEnd) break;
    final barEnd = math.min((lastBeat * samplesPerBeat).round(), contentEnd);
    final barSustain = math.max(1, barEnd - barStart);
    final chordDegreeSemitones =
        _chordRootSemitones(bar, barCount, progression);
    final chordRootSemitones = rootSemitones + chordDegreeSemitones;
    final chordTones = _diatonicChordTones(
      major: major,
      rootSemitones: chordDegreeSemitones,
    );
    final chordRootMidi = 45 + zoomOctave * 12 + chordRootSemitones;
    final bassMidi = _voiceBassMidi(chordRootMidi - 12, previousBassMidi);
    previousBassMidi = bassMidi;
    final barVelocity = _musicVelocity(barEnergy, barDetail);
    final harmonicBoost = barEnergy.clamp(0.0, 1.0) * 0.22;

    events.add(_MusicEvent(
      startSample: barStart,
      sustainSamples: barSustain,
      midi: bassMidi,
      velocity: (barVelocity * bassScale).clamp(0.0, 1.15),
      harmonicBoost: harmonicBoost * 0.5,
      voice: _MusicVoice.bass,
    ));
    for (final tone in chordTones) {
      // Open voicing. The pad's root stays at the chord root so it sits one
      // octave above the bass and bridges it; only the third and fifth take
      // the register lift. Lifting the whole triad left two full octaves of
      // nothing between bass and pad, which is audible as a hollow middle.
      final lift = tone == 0 ? 0 : padRegister;
      events.add(_MusicEvent(
        startSample: barStart,
        sustainSamples: barSustain,
        midi: chordRootMidi + lift + tone,
        velocity: (barVelocity * 0.8 * padScale).clamp(0.0, 1.15),
        harmonicBoost: harmonicBoost,
        voice: _MusicVoice.pad,
      ));
    }

    // Dark bar: the chord holds, but nothing plays over it.
    if (barIsDark) continue;

    for (var beat = firstBeat; beat < lastBeat; beat++) {
      final summary = beats[beat];
      if (summary.energy < 0.06) continue;
      final beatInBar = beat - firstBeat;
      final closesBar = beatInBar == _musicBeatsPerBar - 1 &&
          lastBeat - firstBeat == _musicBeatsPerBar;
      final beatStart = (beat * samplesPerBeat).round();
      if (beatStart >= contentEnd) break;
      final beatEnd =
          math.min(((beat + 1) * samplesPerBeat).round(), contentEnd);

      // Compact drum kit: General MIDI pitch numbers identify kick (36),
      // snare (38), and closed hat (42). Energy keeps the pulse alive while
      // rendered edge detail determines whether the restrained eighth-note hat
      // subdivision appears. Motion gives the next bar a slightly stronger
      // pickup without changing harmony.
      final drumLength = math.max(1, (sampleRate * 0.16).round());
      final drumVelocity =
          (0.26 + summary.energy * 0.42 + rhythmComplexity * 0.12)
              .clamp(0.0, 0.80);
      events.add(_MusicEvent(
        startSample: beatStart,
        sustainSamples: drumLength,
        midi: beatInBar.isEven ? 36 : 38,
        velocity: drumVelocity,
        harmonicBoost: summary.detail,
        voice: _MusicVoice.percussion,
      ));
      if (summary.detail >= 0.12 * (1 - rhythmComplexity * 0.65)) {
        final halfBeat = ((beatEnd - beatStart) * 0.5).round();
        for (final offset in [0, halfBeat]) {
          if (beatStart + offset >= contentEnd) continue;
          events.add(_MusicEvent(
            startSample: beatStart + offset,
            sustainSamples: math.max(1, (sampleRate * 0.07).round()),
            midi: 42,
            velocity: (0.16 +
                    summary.detail * 0.30 +
                    (closesBar ? effectiveMotion * 0.10 : 0))
                .clamp(0.0, 0.52),
            harmonicBoost: summary.detail,
            voice: _MusicVoice.percussion,
          ));
        }
      }

      if (closesBar) {
        // A still view leaves the bar's last beat empty so the cadence stays
        // audible. A moving one fills it with a pickup into the next chord.
        if (effectiveMotion < _musicFillMotionThreshold) continue;
        final tonicMidi = 45 + zoomOctave * 12 + rootSemitones;
        final nextBar = barCount <= 1 ? 0 : (bar + 1) % barCount;
        final nextChordRoot =
            rootSemitones + _chordRootSemitones(nextBar, barCount, progression);
        final half = math.max(1, ((beatEnd - beatStart) * 0.5).round());
        final fillSustain = math.max(1, (half * 0.9).round());
        // Two eighths approaching the next downbeat from a step below, so the
        // fill leads somewhere instead of just adding noise.
        final approach = _nearestScaleToneMidi(
          midi: 45 + zoomOctave * 12 + nextChordRoot - 1,
          rootMidi: tonicMidi,
          scale: scale,
        );
        final lift = _nearestScaleToneMidi(
          midi: _scanDistanceMidi(summary.leadDistance, zoomOctave, scale) +
              rootSemitones,
          rootMidi: tonicMidi,
          scale: scale,
        );
        for (final (offset, midi) in [(0, lift), (half, approach)]) {
          if (beatStart + offset >= contentEnd) break;
          final voicedMidi = _voiceLeadMidi(
            targetMidi: midi + register,
            previousMidi: previousLeadMidi,
            anchorMidi: firstLeadMidi,
          );
          events.add(_MusicEvent(
            startSample: beatStart + offset,
            sustainSamples: fillSustain,
            midi: voicedMidi,
            velocity: _musicVelocity(summary.energy, summary.detail) * 0.85,
            harmonicBoost: summary.energy.clamp(0.0, 1.0) * 0.14,
            voice: _MusicVoice.lead,
          ));
          firstLeadMidi ??= voicedMidi;
          previousLeadMidi = voicedMidi;
        }
        continue;
      }

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
              chordTones: chordTones,
            )
          : _nearestScaleToneMidi(
              midi: target,
              rootMidi: 45 + zoomOctave * 12 + rootSemitones,
              scale: scale,
            );

      // The radial scan selects pitch class and broad register. Fold only by
      // octaves into the one-octave window around the phrase's first note, then
      // prefer the candidate nearest the previous note. This preserves harmony
      // and image mapping while preventing cumulative register drift and keeping
      // the final note within six semitones of the loop's opening lead.
      final voicedLead = _voiceLeadMidi(
        targetMidi: leadMidi + register,
        previousMidi: previousLeadMidi,
        anchorMidi: firstLeadMidi,
      );
      events.add(_MusicEvent(
        startSample: beatStart,
        sustainSamples: noteSustain,
        midi: voicedLead,
        velocity: _musicVelocity(summary.energy, summary.detail),
        harmonicBoost: summary.energy.clamp(0.0, 1.0) * 0.14,
        voice: _MusicVoice.lead,
      ));
      firstLeadMidi ??= voicedLead;
      previousLeadMidi = voicedLead;
      // A high melody carried by one near-sine reads as thin: at the top
      // register the lead sits around 1.8kHz with almost nothing under it.
      // Doubling an octave below puts body beneath the line without moving
      // the line itself. Only above _musicLeadDoubleMidi, since a low lead is
      // already in a body-rich range and doubling it there just muddies.
      if (voicedLead > _musicLeadDoubleMidi) {
        events.add(_MusicEvent(
          startSample: beatStart,
          sustainSamples: noteSustain,
          midi: voicedLead - 12,
          velocity: _musicVelocity(summary.energy, summary.detail) * 0.5,
          harmonicBoost: summary.energy.clamp(0.0, 1.0) * 0.10,
          voice: _MusicVoice.lead,
        ));
      }

      if (summary.detail >= 0.12 * (1 - rhythmComplexity * 0.65)) {
        events.add(_MusicEvent(
          startSample: beatStart,
          sustainSamples: math.max(1, (samplesPerBeat * 0.25).round()),
          // Texture stays one octave over the final voice-led melody note.
          midi: voicedLead + 12,
          velocity: (summary.detail * textureScale).clamp(0.0, 1.0),
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
  double stereoBias = 0,
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
      final tone = event.voice == _MusicVoice.percussion
          ? _percussionTone(
              midi: event.midi,
              relativeSample: rel,
              sampleRate: sampleRate,
              detail: event.harmonicBoost,
            )
          : _softTone(
              hz: hz,
              sample: i,
              sampleRate: sampleRate,
              harmonic: spec.harmonic + event.harmonicBoost,
              harmony: spec.harmony,
              droneHz: 0,
            );
      bus[i] += tone * envelope * gain;
    }
  }

  for (var i = 0; i < sampleCount; i++) {
    final value = bus[i];
    if (value == 0) continue;
    // Master before the final soft limiter. Its 1 / 0.35 asymptote keeps even
    // an extreme score below the Int16 clamp after constant-power panning,
    // while remaining monotonic so bright images still sound louder than dim.
    final limited = _masterMusicBusValue(value);
    final angle = i / sampleCount * math.pi * 2 - math.pi / 2;
    final pan = (math.cos(angle) * 0.72 + stereoBias.clamp(-1.0, 1.0) * 0.2)
        .clamp(-0.92, 0.92);
    left[i] = _toPcm16(limited, math.sqrt((1 - pan) * 0.5));
    right[i] = _toPcm16(limited, math.sqrt((1 + pan) * 0.5));
  }

  return _wavFromPcm16Stereo(left, right, sampleRate);
}

@visibleForTesting
double debugFractalMusicKickBodySample({
  required int relativeSample,
  required int sampleRate,
}) =>
    _kickBody(relativeSample: relativeSample, sampleRate: sampleRate);

double _kickBody({required int relativeSample, required int sampleRate}) {
  final t = relativeSample / sampleRate;
  // Integrate the exponential frequency sweep into phase. Multiplying an
  // instantaneous frequency by time differentiates to a different (and much
  // faster) sweep, causing the kick to fall below its intended 48 Hz body.
  final cycles = 48 * t + 82 / 24 * (1 - math.exp(-24 * t));
  return math.sin(math.pi * 2 * cycles) * math.exp(-t * 12) * 0.92;
}

@visibleForTesting
double debugFractalMusicPercussionSample({
  required int midi,
  required int relativeSample,
  required int sampleRate,
  required double detail,
}) =>
    _percussionTone(
      midi: midi,
      relativeSample: relativeSample,
      sampleRate: sampleRate,
      detail: detail,
    );

double _percussionTone({
  required int midi,
  required int relativeSample,
  required int sampleRate,
  required double detail,
}) {
  final t = relativeSample / sampleRate;
  // Deterministic pseudo-noise keeps exports reproducible and is filtered by
  // the short instrument envelopes above.
  final noise = math.sin(
      relativeSample * 12.9898 + math.sin(relativeSample * 0.123) * 78.233);
  if (midi == 36) {
    final click = noise * math.exp(-t * 70);
    return _kickBody(
          relativeSample: relativeSample,
          sampleRate: sampleRate,
        ) +
        click * 0.12;
  }
  if (midi == 38) {
    final body = math.sin(math.pi * 2 * 185 * t) * math.exp(-t * 18);
    return body * 0.24 + noise * math.exp(-t * 22) * 0.72;
  }
  final brightness = 0.65 + detail.clamp(0.0, 1.0) * 0.30;
  final metallic = math.sin(math.pi * 2 * 5400 * t) * 0.25 +
      math.sin(math.pi * 2 * 7300 * t) * 0.18;
  return (noise * brightness + metallic) * math.exp(-t * 48);
}

double _masterMusicBusValue(double value) {
  final mastered = value * _musicMasterGain;
  return mastered / (1 + mastered.abs() * _musicMasterLimiterStrength);
}

@visibleForTesting
double debugFractalMusicMasterBusValue(double value) =>
    _masterMusicBusValue(value);

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
({
  double brightness,
  double contrast,
  double detail,
  double hue,
  double saturation
}) debugFractalMusicScanProfile({
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
int get debugFractalMusicProgressionCount => _musicMajorProgressions.length;

@visibleForTesting
List<int> debugFractalMusicProgression({
  required bool major,
  required int index,
}) =>
    _musicProgression(major: major, index: index);

@visibleForTesting
List<int> debugFractalMusicChordTones({
  required bool major,
  required int rootSemitones,
}) =>
    _diatonicChordTones(major: major, rootSemitones: rootSemitones);

@visibleForTesting
int debugFractalMusicVoiceLeadMidi({
  required int targetMidi,
  required int? previousMidi,
  int? anchorMidi,
}) =>
    _voiceLeadMidi(
      targetMidi: targetMidi,
      previousMidi: previousMidi,
      anchorMidi: anchorMidi,
    );

@visibleForTesting
List<({int startSample, int midi, String voice})>
    debugFractalMusicScanScoreEvents({
  required FractalMusicScanFrame scanFrame,
  required double zoom,
  required FractalMusicIdentity identity,
  FourierMusicFeatures? fourierFeatures,
  double motion = 0,
  int sampleRate = 22050,
  double seconds = fractalMusicLoopSeconds,
}) {
  final steps = _scanMusicSteps;
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
  final zoomOctave =
      (math.log(zoom.clamp(0.25, 256)) / math.ln2).round().clamp(-1, 2);
  final events = _composeScanScore(
    smoothedScans: smoothedScans,
    identity: identity,
    motion: motion,
    zoomOctave: zoomOctave,
    sampleCount: (sampleRate * seconds).round(),
    sampleRate: sampleRate,
    seconds: seconds,
    fourierFeatures: fourierFeatures,
  );
  return events
      .map((event) => (
            startSample: event.startSample,
            midi: event.midi,
            voice: event.voice.name,
          ))
      .toList(growable: false);
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

({
  double brightness,
  double contrast,
  double detail,
  double hue,
  double saturation
}) _collapseDistanceProfile(
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
  if (bins.isEmpty) {
    return (brightness: 0, contrast: 0, detail: 0, hue: 0, saturation: 0);
  }
  var brightness = 0.0;
  var brightnessSq = 0.0;
  var detail = 0.0;
  var saturation = 0.0;
  var hueX = 0.0;
  var hueY = 0.0;
  var hueWeight = 0.0;
  for (final bin in bins) {
    brightness += bin.brightness;
    brightnessSq += bin.brightness * bin.brightness;
    detail += bin.detail;
    saturation += bin.saturation;
    final weight = bin.brightness + bin.saturation * 0.25;
    hueX += math.cos(bin.hue * math.pi * 2) * weight;
    hueY += math.sin(bin.hue * math.pi * 2) * weight;
    hueWeight += weight;
  }
  var hue = hueWeight <= 1e-9 ? 0.0 : math.atan2(hueY, hueX) / (math.pi * 2);
  if (hue < 0) hue += 1;
  final meanBrightness = brightness / bins.length;
  // Spread of brightness across the scan, not its average. A stark image and a
  // hazy one can share a mean; this separates them, and it is independent of
  // how bright the image is overall.
  final variance =
      (brightnessSq / bins.length - meanBrightness * meanBrightness)
          .clamp(0.0, 1.0);
  return (
    brightness: meanBrightness.clamp(0.0, 1.0),
    contrast: math.sqrt(variance).clamp(0.0, 1.0),
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

/// Curated progressions, as semitone offsets from the key. Every entry starts
/// on the tonic and ends on a chord that leads back to it, so the loop point
/// lands on a cadence. Index 0 of each is the original pair.
const List<List<int>> _musicMajorProgressions = [
  [0, 9, 5, 7], // I  - vi  - IV  - V
  [0, 5, 9, 7], // I  - IV  - vi  - V
  [0, 7, 9, 5], // I  - V   - vi  - IV
  [0, 2, 9, 7], // I  - ii  - vi  - V
  [0, 9, 2, 7], // I  - vi  - ii  - V
  [0, 5, 0, 7], // I  - IV  - I   - V
  [0, 4, 5, 7], // I  - iii - IV  - V
  [0, 9, 4, 5], // I  - vi  - iii - IV
];

const List<List<int>> _musicMinorProgressions = [
  [0, 8, 3, 10], // i - VI  - III - VII
  [0, 3, 8, 10], // i - III - VI  - VII
  [0, 10, 8, 3], // i - VII - VI  - III
  [0, 5, 8, 10], // i - iv  - VI  - VII
  [0, 8, 10, 5], // i - VI  - VII - iv
  [0, 10, 3, 8], // i - VII - III - VI
  [0, 3, 10, 8], // i - III - VII - VI
  [0, 5, 10, 8], // i - iv  - VII - VI
];

List<int> _musicProgression({required bool major, required int index}) {
  final bank = major ? _musicMajorProgressions : _musicMinorProgressions;
  return bank[index.clamp(0, bank.length - 1)];
}

int _chordRootSemitones(int step, int steps, List<int> progression) {
  if (steps <= 0) return 0;
  final chordIndex =
      ((step * progression.length) ~/ steps).clamp(0, progression.length - 1);
  return progression[chordIndex];
}

/// Triad intervals for a diatonic chord rooted at [rootSemitones] within the
/// piece's major or natural-minor scale. Chord quality belongs to the scale
/// degree, not to the piece as a whole: vi in major is minor, while VI in minor
/// is major. Flattening every chord to the global mode introduces chromatic
/// thirds that make otherwise diatonic progressions sound arbitrarily sour.
List<int> _diatonicChordTones({
  required bool major,
  required int rootSemitones,
}) {
  final degree = rootSemitones % 12;
  if (major) {
    return switch (degree) {
      0 || 5 || 7 => const [0, 4, 7],
      2 || 4 || 9 => const [0, 3, 7],
      11 => const [0, 3, 6],
      _ => const [0, 4, 7],
    };
  }
  return switch (degree) {
    0 || 5 || 7 => const [0, 3, 7],
    3 || 8 || 10 => const [0, 4, 7],
    2 => const [0, 3, 6],
    _ => const [0, 3, 7],
  };
}

int _nearestChordToneMidi({
  required int midi,
  required int chordRootSemitones,
  required int zoomOctave,
  required List<int> chordTones,
}) {
  final rootMidi = 45 + zoomOctave * 12 + chordRootSemitones;
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

int _voiceBassMidi(int targetMidi, int? previousMidi) {
  const minimum = 28;
  const maximum = 52;
  final candidates = <int>[
    for (var octave = -5; octave <= 5; octave++) targetMidi + octave * 12,
  ].where((candidate) => candidate >= minimum && candidate <= maximum).toList();
  if (candidates.isEmpty) return targetMidi;
  if (previousMidi == null) {
    return candidates
        .reduce((a, b) => (a - 40).abs() <= (b - 40).abs() ? a : b);
  }
  return candidates.reduce(
      (a, b) => (a - previousMidi).abs() <= (b - previousMidi).abs() ? a : b);
}

@visibleForTesting
int debugFractalMusicVoiceBassMidi({
  required int targetMidi,
  required int? previousMidi,
}) =>
    _voiceBassMidi(targetMidi, previousMidi);

int _voiceLeadMidi({
  required int targetMidi,
  required int? previousMidi,
  int? anchorMidi,
}) {
  if (previousMidi == null) return targetMidi;
  if (anchorMidi != null) {
    final lower = anchorMidi - 6;
    final upper = anchorMidi + 6;
    var candidate = targetMidi;
    while (candidate < lower) {
      candidate += 12;
    }
    while (candidate > upper) {
      candidate -= 12;
    }
    var closest = candidate;
    for (final alternative in [candidate - 12, candidate + 12]) {
      if (alternative < lower || alternative > upper) continue;
      if ((alternative - previousMidi).abs() < (closest - previousMidi).abs()) {
        closest = alternative;
      }
    }
    return closest;
  }
  var voiced = targetMidi;
  while (voiced - previousMidi > 6) {
    voiced -= 12;
  }
  while (previousMidi - voiced > 6) {
    voiced += 12;
  }
  return voiced;
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
