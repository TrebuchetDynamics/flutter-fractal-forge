import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

const _id = 'ulam_spiral';

// Walk the spiral independently of the shader's closed-form index.
List<(int, int)> _positions(int ring) {
  const directions = [(1, 0), (0, 1), (-1, 0), (0, -1)];
  final cells = [(0, 0), (0, 0)]; // Address by 1-based spiral index.
  final count = (2 * ring + 1) * (2 * ring + 1);
  var x = 0, y = 0, direction = 0;
  for (var length = 1; cells.length <= count; length++) {
    for (var side = 0; side < 2; side++) {
      final (dx, dy) = directions[direction++ % 4];
      for (var step = 0; step < length && cells.length <= count; step++) {
        x += dx;
        y += dy;
        cells.add((x, y));
      }
    }
  }
  return cells;
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

// Dart port of the shader's modular Feistel mixer, not of its prime test.
double _randomUnit(int n) {
  var left = n ~/ 1024, right = n % 1024;
  for (var i = 0; i < 4; i++) {
    final t = right + 17 + 191 * i;
    (left, right) = (right, (left + 73 * (t * t % 1021)) % 1024);
  }
  return (left * 1024 + right) / 1048576;
}

ui.Offset _offset(double x, double y) => ui.Offset(x, -y);

Future<int Function((int, int))> _render(
  FractalModule module, {
  required int side,
  required int pixelsPerCell,
  (int, int) center = (0, 0),
  int startValue = 1,
  int pattern = 0,
}) async {
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  final size = ui.Size.square(side.toDouble());
  final pan = _offset(center.$1.toDouble(), center.$2.toDouble()) / 203;
  module.setUniforms(
    shader,
    FractalRenderState(
      params: {
        ...module.defaultPreset.params,
        'startValue': startValue,
        'pattern': pattern,
      },
      view: module.defaultPreset.view.copyWith(
        pan: Vector2(pan.dx, pan.dy),
        zoom: 203 * pixelsPerCell / side,
      ),
      transparentBackground: true,
    ),
    size,
    0,
  );
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
      .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
  final picture = recorder.endRecording();
  final image = await picture.toImage(side, side);
  final ByteData bytes = (await image.toByteData())!;
  image.dispose();
  picture.dispose();
  shader.dispose();
  return (cell) {
    final dx = cell.$1 - center.$1, dy = cell.$2 - center.$2;
    final pixel = size.center(ui.Offset.zero) +
        _offset(dx.toDouble(), dy.toDouble()) * pixelsPerCell.toDouble();
    expect((ui.Offset.zero & size).contains(pixel), isTrue, reason: '$cell');
    return bytes.getUint8((pixel.dy.floor() * side + pixel.dx.floor()) * 4 + 3);
  };
}

Matcher _alpha(bool lit) =>
    lit ? greaterThanOrEqualTo(200) : inInclusiveRange(20, 120);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();
  FractalModule module() => registry.byId(_id);

  test('exactly one static Number Theory entry with the intended controls', () {
    expect(registry.modules.where((m) => m.id == _id), hasLength(1));
    final entry = CatalogRepository.fromRegistry(registry)
        .entries
        .singleWhere((e) => e.module.id == _id);
    expect(entry.category, 'Number Theory');
    expect(module().displayName(AppLocalizationsEn()), 'Ulam Spiral');
    expect(entry.mathematics.method, 'Ulam prime spiral');
    expect(entry.mathematics.qualification,
        contains('not a self-similar fractal'));
    expect(module().animationCapability, FractalAnimationCapability.static);
    final params = module().parameters;
    expect(params.map((p) => p.id), ['startValue', 'pattern', 'colorScheme']);
    expect(params.first.type, FractalParamType.integer);
    expect((params.first.min, params.first.max, params.first.defaultValue),
        (1, 100, 1));
    expect(params[1].resolvedControl, FractalParamControl.chips);
    expect(params[1].options.map((o) => o.value), [0, 1]);
    expect(params[1].defaultValue, 0);
  });

  test('ring 20 matches the sieve; start 41 lights Euler’s prime runs',
      () async {
    final cells = _positions(20);
    expect([
      for (final n in [2, 3, 4, 5, 9, 10]) cells[n]
    ], [
      (1, 0),
      (1, 1),
      (0, 1),
      (-1, 1),
      (1, -1),
      (2, -1)
    ]);
    final primes = _sieve(cells.length - 1);
    final alpha = await _render(module(), side: 369, pixelsPerCell: 9);
    for (var n = 1; n < cells.length; n++) {
      expect(alpha(cells[n]), _alpha(primes[n]), reason: 'n=$n at ${cells[n]}');
    }
    final euler =
        await _render(module(), side: 369, pixelsPerCell: 9, startValue: 41);
    for (var m = 0; m <= 39; m++) {
      expect(euler(cells[m * m + m + 1]), _alpha(true), reason: 'm=$m');
    }
  });

  test('trial division is exact near the range limit; ring 501 is empty',
      () async {
    final cells = _positions(500);
    for (final (n, lit) in [(999983, true), (999919, false), (994009, false)]) {
      final alpha =
          await _render(module(), side: 45, pixelsPerCell: 9, center: cells[n]);
      expect(alpha(cells[n]), _alpha(lit), reason: 'n=$n');
    }
    final edge = await _render(module(),
        side: 45, pixelsPerCell: 9, center: (500, -500));
    expect(edge((500, -500)), _alpha(false));
    expect(edge((501, -500)), 0);
  });

  test('random comparison matches the hash at the expected prime density',
      () async {
    final cells = _positions(100);
    final primes = _sieve(cells.length - 1);
    final alpha =
        await _render(module(), side: 1005, pixelsPerCell: 5, pattern: 1);
    var litCount = 0, primeCount = 0, different = 0;
    for (var n = 1; n < cells.length; n++) {
      final expected = n >= 2 && _randomUnit(n) < 1 / math.log(n);
      final sample = alpha(cells[n]);
      expect(sample, _alpha(expected), reason: 'n=$n');
      final lit = sample >= 200;
      if (lit) litCount++;
      if (primes[n]) primeCount++;
      if (lit != primes[n]) different++;
    }
    expect(litCount, closeTo(primeCount, primeCount * .1));
    expect(different, greaterThan(0));
  });

  test('default fully frames the first 101 rings in either orientation', () {
    final view = module().defaultPreset.view;
    expect(view.zoom, 1);
    expect(view.pan.length, 0);
    for (final size in [const ui.Size(1920, 1080), const ui.Size(1080, 1920)]) {
      final pixelsPerCell = view.zoom * math.min(size.width, size.height) / 203;
      final viewport = ui.Offset.zero & size;
      for (final x in [-100.5, 100.5]) {
        for (final y in [-100.5, 100.5]) {
          final pixel =
              size.center(ui.Offset.zero) + _offset(x, y) * pixelsPerCell;
          expect(viewport.contains(pixel), isTrue);
        }
      }
    }
  });

  test('zoom does not change the centre value or the pattern', () {
    final controller = FractalController(registry)
      ..selectModule(module(), animate: false);
    addTearDown(controller.dispose);
    controller.updateParam('startValue', 41);
    controller.updateParam('pattern', 1);
    controller.updateZoom(32);
    expect(controller.view.zoom, 32);
    expect(controller.params['startValue'], 41);
    expect(controller.params['pattern'], 1);
  });
}
