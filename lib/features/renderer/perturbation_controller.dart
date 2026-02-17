import 'dart:ui' as ui;

typedef DD = ({double hi, double lo});

DD ddFromDouble(double v) => (hi: v, lo: 0.0);

DD ddAdd(DD a, DD b) {
  final s = a.hi + b.hi;
  final v = s - a.hi;
  final e = (a.hi - (s - v)) + (b.hi - v) + a.lo + b.lo;
  return (hi: s, lo: e);
}

DD ddSub(DD a, DD b) => ddAdd(a, (hi: -b.hi, lo: -b.lo));

DD ddMul(DD a, DD b) {
  // Dekker split constants for IEEE 754 double.
  const split = 134217729.0; // 2^27 + 1

  final p = a.hi * b.hi;

  final aC = split * a.hi;
  final aHi = aC - (aC - a.hi);
  final aLo = a.hi - aHi;

  final bC = split * b.hi;
  final bHi = bC - (bC - b.hi);
  final bLo = b.hi - bHi;

  final err = ((aHi * bHi - p) + aHi * bLo + aLo * bHi) + aLo * bLo;
  final r = a.hi * b.lo + a.lo * b.hi + err + a.lo * b.lo;

  return (hi: p, lo: r);
}

DD ddSquare(DD a) => ddMul(a, a);

double ddToDouble(DD a) => a.hi + a.lo;

List<(double zr, double zi)>? computeReferenceOrbit({
  required double cRefRe,
  required double cRefIm,
  required int maxIter,
  required double bailout,
}) {
  if (maxIter <= 0) {
    return <(double, double)>[];
  }

  final bailoutSq = bailout * bailout;
  final orbit = <(double, double)>[];

  var zr = ddFromDouble(0.0);
  var zi = ddFromDouble(0.0);
  final cr = ddFromDouble(cRefRe);
  final ci = ddFromDouble(cRefIm);

  for (var n = 0; n < maxIter; n++) {
    final zrDouble = ddToDouble(zr);
    final ziDouble = ddToDouble(zi);
    orbit.add((zrDouble, ziDouble));

    if (zrDouble * zrDouble + ziDouble * ziDouble > bailoutSq) {
      while (orbit.length < maxIter) {
        orbit.add(orbit.last);
      }
      return orbit;
    }

    final zr2 = ddSquare(zr);
    final zi2 = ddSquare(zi);
    final zrzi = ddMul(zr, zi);

    final newZr = ddAdd(ddSub(zr2, zi2), cr);
    final newZi = ddAdd((hi: 2.0 * zrzi.hi, lo: 2.0 * zrzi.lo), ci);

    zr = newZr;
    zi = newZi;
  }

  return orbit;
}

/// Encodes orbit as a ui.Image using Impeller-safe RG normalization.
///
/// Each float v (in range [-4, 4]) is stored in one RGBA pixel as:
///   R = coarse: (v + 4.0) / 8.0          → [0, 1]
///   G = fine:   fract((v + 4.0) / 8.0 * 256.0) / 256.0  → [0, 1/256]
/// Shader decode: v = R * 8.0 - 4.0 + G * 8.0
///
/// Precision: 8/256 ≈ 0.031 per fine step — sufficient for orbit
/// values within the bailout radius (≤ 8.0). Avoids all integer bit ops
/// so it compiles cleanly under Impeller/SPIR-V.
///
/// Layout: width = n*2, height = 1
///   pixel[n*2]   = zr encoding
///   pixel[n*2+1] = zi encoding
ui.Image encodeOrbitTexture(List<(double zr, double zi)> orbit) {
  final n = orbit.length;
  final pixelCount = n * 2;

  // Encode a float in [-4, 4] into (r, g) bytes [0..255]
  (int r, int g) encodeFloat(double value) {
    final mapped = (value.clamp(-4.0, 4.0) + 4.0) / 8.0; // [0, 1]
    final scaled = mapped * 256.0;
    final coarse = scaled.floor().clamp(0, 255);
    final fine = ((scaled - coarse) * 255.0).round().clamp(0, 255);
    return (coarse, fine);
  }

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, pixelCount.toDouble(), 1),
  );

  for (var i = 0; i < n; i++) {
    final (rR, gR) = encodeFloat(orbit[i].$1); // zr
    final (rI, gI) = encodeFloat(orbit[i].$2); // zi

    canvas.drawRect(
      ui.Rect.fromLTWH((i * 2).toDouble(), 0, 1, 1),
      ui.Paint()..color = ui.Color.fromARGB(255, rR, gR, 0),
    );
    canvas.drawRect(
      ui.Rect.fromLTWH((i * 2 + 1).toDouble(), 0, 1, 1),
      ui.Paint()..color = ui.Color.fromARGB(255, rI, gI, 0),
    );
  }

  final picture = recorder.endRecording();
  return picture.toImageSync(pixelCount, 1);
}
