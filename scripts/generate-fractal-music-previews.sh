#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$ROOT/artifacts/fractal_music_preview}"
FLUTTER="${FLUTTER:-flutter}"
TMP_TEST="$(mktemp /tmp/fractal_music_preview_writer.XXXXXX_test.dart)"
trap 'rm -f "$TMP_TEST"' EXIT

cat > "$TMP_TEST" <<'DART'
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('write fractal music preview wavs', () {
    final outDir = Directory(Platform.environment['OUT_DIR']!)
      ..createSync(recursive: true);
    final samples = <String, Uint8List>{
      '01-dark-silence.wav': buildFractalMusicScanWav(
        scanFrame: FractalMusicScanFrame(
          rgba: Uint8List(64 * 64 * 4),
          width: 64,
          height: 64,
        ),
        zoom: 1,
      ),
      '02-red-field.wav': buildFractalMusicScanWav(
        scanFrame: FractalMusicScanFrame(
          rgba: solidFrame(64, 64, 255, 0, 0),
          width: 64,
          height: 64,
        ),
        zoom: 1,
      ),
      '03-cyan-field.wav': buildFractalMusicScanWav(
        scanFrame: FractalMusicScanFrame(
          rgba: solidFrame(64, 64, 0, 180, 180),
          width: 64,
          height: 64,
        ),
        zoom: 1,
      ),
      '04-right-edge-detail.wav': buildFractalMusicScanWav(
        scanFrame: FractalMusicScanFrame(
          rgba: rightEdgeDetailFrame(96, 64),
          width: 96,
          height: 64,
        ),
        zoom: 4,
      ),
      // Same frame as 04, but as if the view had just moved: the bar-closing
      // rests become pickup fills. A/B these two to hear motion-as-rhythm.
      '06-motion-fill.wav': buildFractalMusicScanWav(
        scanFrame: FractalMusicScanFrame(
          rgba: rightEdgeDetailFrame(96, 64),
          width: 96,
          height: 64,
        ),
        zoom: 4,
        motion: 0.4,
      ),
      '05-state-fallback.wav': buildFractalMusicWav(
        moduleId: 'mandelbrot',
        params: const {'iterations': 180, 'colorScheme': 5},
        panX: -0.7435,
        panY: 0.1314,
        zoom: 12,
      ),
    };

    for (final entry in samples.entries) {
      final file = File('${outDir.path}/${entry.key}');
      file.writeAsBytesSync(entry.value, flush: true);
      print('${file.path} ${entry.value.length}');
      expect(file.lengthSync(), entry.value.length);
    }

    writeRealCapturePreviews(outDir);
  });
}

/// Renders previews from real viewer captures in screenshots/.
///
/// The synthetic panel above is the reproducible baseline; it uses solid
/// fields, so it exercises neither the tempo bands nor the progression bank.
/// These do. screenshots/ is gitignored, so this is skipped on a fresh clone
/// and in CI rather than failing.
void writeRealCapturePreviews(Directory outDir) {
  final captures = Directory('screenshots');
  if (!captures.existsSync()) {
    print('screenshots/ absent - skipping real-capture previews');
    return;
  }

  final files = captures
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final decoded = img.decodePng(file.readAsBytesSync());
    if (decoded == null) continue;

    // Match the live capture path in fractal_viewer_screen.dart: pixelRatio
    // 0.25 of the viewer surface.
    final small = img.copyResize(
      decoded,
      width: (decoded.width * 0.25).round(),
      height: (decoded.height * 0.25).round(),
    );
    final rgba = Uint8List(small.width * small.height * 4);
    var i = 0;
    for (var y = 0; y < small.height; y++) {
      for (var x = 0; x < small.width; x++) {
        final pixel = small.getPixel(x, y);
        rgba[i++] = pixel.r.toInt();
        rgba[i++] = pixel.g.toInt();
        rgba[i++] = pixel.b.toInt();
        rgba[i++] = 255;
      }
    }
    final frame = FractalMusicScanFrame(
      rgba: rgba,
      width: small.width,
      height: small.height,
    );

    final features = fractalMusicFeaturesOf(frame);
    // A capture that came out black carries no music and would only trip the
    // panel's loudness checks. Blank GPU captures do happen.
    if (features.brightness < 0.01) {
      print('skipping ${file.uri.pathSegments.last}: capture is near-black');
      continue;
    }

    final identity = resolveFractalMusicIdentity(features);
    final wav = buildFractalMusicScanWav(
      scanFrame: frame,
      zoom: 1,
      identity: identity,
    );

    final label = file.uri.pathSegments.last
        .replaceAll('.png', '')
        .replaceAll('_', '-');
    // rootSemitones is an offset from the composer's base pitch, MIDI 45 (A2),
    // not from C -- so the sounding key is nine semitones up from a naive
    // C-indexed lookup.
    final key = noteNames[(identity.rootSemitones + 9) % 12];
    final mode = identity.major ? 'maj' : 'min';
    final name = 'real-$label-$key$mode-${identity.bpm}bpm'
        '-prog${identity.progressionIndex}'
        '-reg${identity.registerSemitones}.wav';
    File('${outDir.path}/$name').writeAsBytesSync(wav, flush: true);
    print('${outDir.path}/$name  <- '
        'brightness=${features.brightness.toStringAsFixed(3)} '
        'detail=${features.detail.toStringAsFixed(3)} '
        'hue=${features.hue.toStringAsFixed(3)} '
        'saturation=${features.saturation.toStringAsFixed(3)}');
  }
}

const noteNames = [
  'C',
  'Cs',
  'D',
  'Ds',
  'E',
  'F',
  'Fs',
  'G',
  'Gs',
  'A',
  'As',
  'B',
];

Uint8List solidFrame(int width, int height, int r, int g, int b) {
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

Uint8List rightEdgeDetailFrame(int width, int height) {
  final frame = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final offset = (y * width + x) * 4;
      final edge = x > width * 0.62;
      final stripe = ((x + y) ~/ 4).isEven;
      frame[offset] = edge && stripe ? 255 : 10;
      frame[offset + 1] = edge ? 180 : 20;
      frame[offset + 2] = edge && !stripe ? 255 : 40;
      frame[offset + 3] = 255;
    }
  }
  return frame;
}
DART

mkdir -p "$OUT_DIR"
cd "$ROOT"
OUT_DIR="$OUT_DIR" "$FLUTTER" test "$TMP_TEST" --reporter expanded
python3 - "$OUT_DIR" <<'PY'
import json
import math
import struct
import sys
import wave
from pathlib import Path

out_dir = Path(sys.argv[1])
manifest = {}
mono_by_name = {}
failed = False
for path in sorted(out_dir.glob('*.wav')):
    with wave.open(str(path), 'rb') as wav:
        channels = wav.getnchannels()
        sample_rate = wav.getframerate()
        frames = wav.getnframes()
        raw = wav.readframes(frames)
    samples = struct.unpack('<' + 'h' * (len(raw) // 2), raw) if raw else ()
    peak = max((abs(s) for s in samples), default=0)
    mean = abs(sum(samples) / len(samples)) if samples else 0.0
    nonzero_ratio = sum(1 for s in samples if s != 0) / len(samples) if samples else 0.0
    rms = math.sqrt(sum(s * s for s in samples) / len(samples)) if samples else 0.0
    mono = [sum(samples[i:i + channels]) / channels for i in range(0, len(samples), channels)] if channels else []
    mono_by_name[path.name] = mono
    deltas = [abs(mono[i] - mono[i - 1]) for i in range(1, len(mono))]
    max_delta = max(deltas, default=0.0)
    zero_crossings = sum(
        1
        for i in range(1, len(mono))
        if (mono[i - 1] < 0 <= mono[i]) or (mono[i - 1] > 0 >= mono[i])
    )
    zero_crossing_ratio = zero_crossings / len(mono) if mono else 0.0
    first_frame_abs = max((abs(s) for s in samples[:channels]), default=0)
    last_frame_abs = max((abs(s) for s in samples[-channels:]), default=0)
    seconds = frames / sample_rate if sample_rate else 0
    issues = []
    if channels != 2:
        issues.append(f'expected stereo, got {channels} channel(s)')
    if sample_rate != 22050:
        issues.append(f'expected 22050 Hz, got {sample_rate}')
    if abs(seconds - 24.0) > 0.01:
        issues.append(f'expected 24.0 seconds, got {seconds:.3f}')
    if mean > 64:
        issues.append(f'DC offset too high: {mean:.3f}')
    if path.name == '01-dark-silence.wav':
        if peak != 0 or rms != 0 or nonzero_ratio != 0:
            issues.append('dark silence preview should remain silent')
    else:
        if peak < 300:
            issues.append(f'peak too quiet: {peak}')
        if peak > 12000:
            issues.append(f'peak too loud / clipping risk: {peak}')
        if rms < 100:
            issues.append(f'RMS too quiet: {rms:.3f}')
        if rms > 5000:
            issues.append(f'RMS too loud / fatigue risk: {rms:.3f}')
        if nonzero_ratio < 0.85:
            issues.append(f'too much silence/dropout: {nonzero_ratio:.4f}')
        if max_delta > 4096:
            issues.append(f'large adjacent-sample jump / click risk: {max_delta:.1f}')
        if zero_crossing_ratio > 0.18:
            issues.append(f'high zero-crossing rate / harshness risk: {zero_crossing_ratio:.4f}')
    if first_frame_abs > 32:
        issues.append(f'first frame not near silence: {first_frame_abs}')
    if last_frame_abs > 32:
        issues.append(f'last frame not near silence: {last_frame_abs}')
    failed = failed or bool(issues)
    manifest[path.name] = {
        'channels': channels,
        'sampleRate': sample_rate,
        'frames': frames,
        'seconds': round(seconds, 3),
        'peak': peak,
        'meanAbsOffset': round(mean, 3),
        'rms': round(rms, 3),
        'nonzeroRatio': round(nonzero_ratio, 4),
        'maxAdjacentDelta': round(max_delta, 3),
        'zeroCrossingRatio': round(zero_crossing_ratio, 4),
        'firstFrameAbs': first_frame_abs,
        'lastFrameAbs': last_frame_abs,
        'health': 'fail' if issues else 'pass',
        'issues': issues,
    }

def waveform_similarity(a, b):
    count = min(len(a), len(b))
    if count == 0:
        return {'correlation': 1.0, 'rmsDifference': 0.0}
    a = a[:count]
    b = b[:count]
    dot = sum(x * y for x, y in zip(a, b))
    norm_a = math.sqrt(sum(x * x for x in a))
    norm_b = math.sqrt(sum(y * y for y in b))
    correlation = dot / (norm_a * norm_b) if norm_a and norm_b else 1.0
    rms_difference = math.sqrt(sum((x - y) * (x - y) for x, y in zip(a, b)) / count)
    return {
        'correlation': round(correlation, 4),
        'rmsDifference': round(rms_difference, 3),
    }

red_cyan = waveform_similarity(
    mono_by_name.get('02-red-field.wav', []),
    mono_by_name.get('03-cyan-field.wav', []),
)
for name in ('02-red-field.wav', '03-cyan-field.wav'):
    manifest[name]['visualDistinctnessVsOtherColor'] = red_cyan
if abs(red_cyan['correlation']) > 0.85 or red_cyan['rmsDifference'] < 150:
    message = (
        'red and cyan previews are too similar; visual color is not audible '
        f"enough: correlation={red_cyan['correlation']}, "
        f"rmsDifference={red_cyan['rmsDifference']}"
    )
    for name in ('02-red-field.wav', '03-cyan-field.wav'):
        manifest[name]['issues'].append(message)
        manifest[name]['health'] = 'fail'
    failed = True

manifest_path = out_dir / 'manifest.json'
manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
print(manifest_path)
if failed:
    print('Preview audio health check failed', file=sys.stderr)
    sys.exit(1)
PY
ls -lh "$OUT_DIR"
