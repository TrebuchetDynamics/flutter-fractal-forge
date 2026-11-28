import 'dart:typed_data';
import 'dart:ui' as ui;

// Existing locked test dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

const _cellScale = 72.0;
const _pixelsPerCell = 5;

// Walk the spiral independently of the shader's closed-form index.
Iterable<(int, int, int)> _cells(int limit) sync* {
  const directions = [(1, 0), (0, 1), (-1, 0), (0, -1)];
  var n = 1, x = 0, y = 0, direction = 0;
  yield (n, x, y);
  for (var length = 1; n < limit; length++) {
    for (var side = 0; side < 2; side++) {
      final (dx, dy) = directions[direction++ % 4];
      for (var step = 0; step < length && n < limit; step++) {
        x += dx;
        y += dy;
        yield (++n, x, y);
      }
    }
  }
}

List<bool> _sieve(int limit) {
  final primes = List.filled(limit + 1, true);
  primes[0] = primes[1] = false;
  for (var d = 2; d * d <= limit; d++) {
    if (!primes[d]) continue;
    for (var n = d * d; n <= limit; n += d) {
      primes[n] = false;
    }
  }
  return primes;
}

Future<ByteData> _render(
  FractalModule module, {
  required int side,
  int variant = 1,
  Vector2? pan,
  double? zoom,
}) async {
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  final size = ui.Size.square(side.toDouble());
  final preset = module.defaultPreset;
  module.setUniforms(
    shader,
    FractalRenderState(
      params: {...preset.params, 'variant': variant},
      view: preset.view.copyWith(pan: pan, zoom: zoom),
      transparentBackground: variant == 1,
    ),
    size,
    0,
  );
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
      .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
  final picture = recorder.endRecording();
  final image = await picture.toImage(side, side);
  final bytes = (await image.toByteData())!;
  image.dispose();
  picture.dispose();
  shader.dispose();
  return bytes;
}

// Invert the shader's floor(p * cellScale) at the centre of a cell.
Vector2 _panAt(int x, int y) =>
    Vector2((x + .5) / _cellScale, (y + .5) / _cellScale);

double _zoomFor(int side) => _cellScale * _pixelsPerCell / side;

int _alpha(ByteData bytes, int side, int x, int y) =>
    bytes.getUint8((y * side + x) * 4 + 3);

Matcher _lit(bool prime) =>
    prime ? greaterThanOrEqualTo(200) : lessThanOrEqualTo(60);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final module = ModuleRegistry().byId('pascal_ulam_number_fractals');

  test('Ulam rejects large composites and still lights nearby primes',
      () async {
    const expected = {
      17161: false, // 131²
      17947: false, // 131 × 137
      994009: false, // 997²
      999919: false, // 991 × 1009
      17159: true,
      999983: true,
    };
    final positions = {
      for (final (n, x, y) in _cells(999983))
        if (expected.containsKey(n)) n: (x, y),
    };
    const side = 25;
    for (final MapEntry(key: n, value: prime) in expected.entries) {
      final (x, y) = positions[n]!;
      expect(x != 0 && y != 0, isTrue, reason: 'axis at n=$n');
      final pixels = await _render(module,
          side: side, pan: _panAt(x, y), zoom: _zoomFor(side));
      expect(_alpha(pixels, side, side ~/ 2, side ~/ 2), _lit(prime),
          reason: 'n=$n at ($x, $y)');
    }
  });

  test('Ulam off-axis cells through ring 20 match an independent sieve',
      () async {
    const side = 41 * _pixelsPerCell;
    const limit = 41 * 41;
    final primes = _sieve(limit);
    final pixels = await _render(module,
        side: side, pan: _panAt(0, 0), zoom: _zoomFor(side));
    for (final (n, x, y) in _cells(limit)) {
      if (x == 0 || y == 0) continue;
      final px = side ~/ 2 + x * _pixelsPerCell;
      final py = side ~/ 2 + y * _pixelsPerCell;
      final reason = 'n=$n at ($x, $y)';
      if (x.abs() == 1 || y.abs() == 1) {
        // The existing axis glow extends to the adjacent cells and makes
        // even composites opaque there. Distinguish the prime palette from
        // the axis-only sRGB colour instead of changing that glow.
        final rgba = pixels.getUint32((py * side + px) * 4);
        expect(rgba, primes[n] ? isNot(0x2f2f37ff) : 0x2f2f37ff,
            reason: reason);
      } else {
        expect(_alpha(pixels, side, px, py), _lit(primes[n]), reason: reason);
      }
    }
  });

  test('Ulam leaves ring 501 and far pixels at minimum zoom transparent',
      () async {
    const side = 25;
    final edge = await _render(module,
        side: side, pan: _panAt(500, 0), zoom: _zoomFor(side));
    const mid = side ~/ 2;
    // The in-range axis remains lit, but the next cell loses the axis too.
    expect(_alpha(edge, side, mid, mid), _lit(true));
    expect(_alpha(edge, side, mid + _pixelsPerCell, mid), 0);

    final zoomedOut = await _render(module, side: side, zoom: 1e-9);
    expect(_alpha(zoomedOut, side, mid + _pixelsPerCell, mid), 0);
  });

  test('Pascal default pixels match the frozen base render', () async {
    final pixels = await _render(module, side: 128, variant: 0);
    // Pinned flutter_tester RGBA, 128x128 at t=0 on 5b992912.
    expect(sha256.convert(pixels.buffer.asUint8List()).toString(),
        'f1006b4b41c77796d0537a57127dae89ee01a60efe0ebb960e43685f4558cea8');
  });
}
