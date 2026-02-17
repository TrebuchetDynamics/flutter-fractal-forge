import 'dart:typed_data';
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

ui.Image encodeOrbitTexture(List<(double zr, double zi)> orbit) {
  final n = orbit.length;
  final pixelCount = n * 2;
  final bytes = Uint8List(pixelCount * 4);

  void encodeFloat(int pixelIdx, double value) {
    final buf = ByteData(4)..setFloat32(0, value, Endian.little);
    final base = pixelIdx * 4;
    bytes[base] = buf.getUint8(0);
    bytes[base + 1] = buf.getUint8(1);
    bytes[base + 2] = buf.getUint8(2);
    bytes[base + 3] = buf.getUint8(3);
  }

  for (var i = 0; i < n; i++) {
    encodeFloat(i * 2, orbit[i].$1);
    encodeFloat(i * 2 + 1, orbit[i].$2);
  }

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, pixelCount.toDouble(), 1),
  );

  for (var i = 0; i < pixelCount; i++) {
    final base = i * 4;
    final color = ui.Color.fromARGB(
      bytes[base + 3],
      bytes[base],
      bytes[base + 1],
      bytes[base + 2],
    );
    canvas.drawRect(
      ui.Rect.fromLTWH(i.toDouble(), 0, 1, 1),
      ui.Paint()..color = color,
    );
  }

  final picture = recorder.endRecording();
  return picture.toImageSync(pixelCount, 1);
}
