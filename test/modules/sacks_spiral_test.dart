import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

const _id = 'sacks_spiral';
const _limit = 1600;
const _pixelsPerUnit = 9.0;

ui.Offset _position(int n) {
  final radius = math.sqrt(n);
  final angle = 2 * math.pi * radius;
  return ui.Offset(radius * math.cos(angle), radius * math.sin(angle));
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

ui.Offset _pixel(
    ui.Size size, ui.Offset point, ui.Offset center, double scale) {
  final delta = point - center;
  return size.center(ui.Offset.zero) + ui.Offset(delta.dx, -delta.dy) * scale;
}

Future<List<int> Function(ui.Offset)> _render(
  FractalModule module, {
  int side = 731,
  ui.Offset center = ui.Offset.zero,
  int marks = 0,
  int palette = 1,
  double pixelsPerUnit = _pixelsPerUnit,
}) async {
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  final size = ui.Size.square(side.toDouble());
  module.setUniforms(
    shader,
    FractalRenderState(
      params: {
        ...module.defaultPreset.params,
        'marks': marks,
        'colorScheme': palette
      },
      view: module.defaultPreset.view.copyWith(
        pan: Vector2(center.dx / 203, -center.dy / 203),
        zoom: 203 * pixelsPerUnit / side,
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
  final bytes =
      (await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba))!;
  image.dispose();
  picture.dispose();
  shader.dispose();
  return (point) {
    final pixel = _pixel(size, point, center, pixelsPerUnit);
    expect((ui.Offset.zero & size).contains(pixel), isTrue, reason: '$point');
    final offset = (pixel.dy.floor() * side + pixel.dx.floor()) * 4;
    return List.generate(4, (channel) => bytes.getUint8(offset + channel));
  };
}

Matcher _alpha(bool lit) =>
    lit ? greaterThanOrEqualTo(200) : inInclusiveRange(20, 120);

// At high magnification, estimate the centre from the alpha-weighted
// cross-sections through the expected dot, not just its lit centre pixel.
Future<ui.Offset> _measuredCenter(FractalModule module, ui.Offset point) async {
  const scale = 128.0;
  const halfSpan = 64;
  final sample = await _render(module,
      side: 2 * halfSpan + 1, center: point, pixelsPerUnit: scale);
  double displacement(ui.Offset axis) {
    var total = 0, moment = 0;
    for (var i = -halfSpan; i <= halfSpan; i++) {
      final alpha = sample(point + axis * (i / scale))[3];
      total += alpha;
      moment += i * alpha;
    }
    expect(total, greaterThan(0));
    return moment / (total * scale);
  }

  return point +
      ui.Offset(displacement(const ui.Offset(1, 0)),
          displacement(const ui.Offset(0, 1)));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();
  FractalModule module() => registry.byId(_id);

  test('one static Number Theory entry with the intended controls', () {
    expect(registry.modules.where((m) => m.id == _id), hasLength(1));
    final entry = CatalogRepository.fromRegistry(registry)
        .entries
        .singleWhere((e) => e.module.id == _id);
    expect(entry.category, 'Number Theory');
    expect(module().displayName(AppLocalizationsEn()), 'Sacks Spiral');
    expect(entry.mathematics.method, 'Sacks number spiral');
    expect(entry.mathematics.qualification,
        contains('not a self-similar fractal'));
    expect(module().animationCapability, FractalAnimationCapability.static);
    final parameters = module().parameters;
    expect(parameters.map((p) => p.id), ['marks', 'colorScheme']);
    expect(parameters.first.resolvedControl, FractalParamControl.chips);
    expect(parameters.first.options.map((o) => o.value), [0, 1]);
    expect(parameters.first.defaultValue, 0);
    expect(module().defaultPreset.params['marks'], 0);
  });

  test('first 1600 dots match the sieve, with squares on the positive x-axis',
      () async {
    final primes = _sieve(_limit);
    final sample = await _render(module());
    for (var n = 1; n <= _limit; n++) {
      expect(sample(_position(n))[3], _alpha(primes[n]), reason: 'n=$n');
    }
    for (var k = 1; k <= 40; k++) {
      final axis = ui.Offset(k.toDouble(), 0);
      expect(sample(axis)[3], _alpha(false), reason: '$k²');
      final center = await _measuredCenter(module(), axis);
      expect((center - axis).distance, lessThanOrEqualTo(0.01), reason: '$k²');
    }
    expect(sample(ui.Offset.zero)[3], lessThanOrEqualTo(10));
    expect(sample(const ui.Offset(1.5, 0))[3], lessThanOrEqualTo(10));
  });

  test(
      'dots near radius 1000 are classified exactly and the range ends at 1001',
      () async {
    for (final (n, lit) in [(999983, true), (999919, false), (994009, false)]) {
      final point = _position(n);
      final sample = await _render(module(), side: 45, center: point);
      expect(sample(point)[3], _alpha(lit), reason: 'n=$n');
      final center = await _measuredCenter(module(), point);
      expect((center - point).distance, lessThanOrEqualTo(0.01),
          reason: 'n=$n');
    }
    final edge =
        await _render(module(), side: 45, center: const ui.Offset(1001, 0));
    expect(edge(const ui.Offset(1001, 0))[3], _alpha(false));
    expect(edge(const ui.Offset(1002, 0))[3], lessThanOrEqualTo(10));
  });

  test('every palette distinguishes squares without recoloring primes',
      () async {
    final primes = _sieve(_limit);
    final primeDots = [
      for (var n = 2; n <= _limit; n++)
        if (primes[n]) _position(n)
    ];
    for (var palette = 0; palette < 4; palette++) {
      final plain = await _render(module(), palette: palette);
      final marked = await _render(module(), palette: palette, marks: 1);
      for (final point in primeDots) {
        expect(marked(point), plain(point),
            reason: 'prime at $point, palette $palette');
      }
      for (var k = 1; k <= 40; k++) {
        final point = ui.Offset(k.toDouble(), 0);
        final nearest = primeDots.reduce((a, b) =>
            (a - point).distanceSquared < (b - point).distanceSquared ? a : b);
        final square = marked(point);
        final prime = marked(nearest);
        expect(square[3], _alpha(true), reason: '$k², palette $palette');
        expect(
            [for (var c = 0; c < 3; c++) (square[c] - prime[c]).abs()]
                .reduce(math.max),
            greaterThanOrEqualTo(64),
            reason: '$k², palette $palette');
      }
    }
  });

  test('default frames radius 100 in landscape and portrait', () {
    final view = module().defaultPreset.view;
    expect(view.zoom, 1);
    expect(view.pan.length, 0);
    for (final size in [const ui.Size(1920, 1080), const ui.Size(1080, 1920)]) {
      final scale = view.zoom * size.shortestSide / 203;
      for (final x in [-100.0, 100.0]) {
        for (final y in [-100.0, 100.0]) {
          expect(
              (ui.Offset.zero & size).contains(
                  _pixel(size, ui.Offset(x, y), ui.Offset.zero, scale)),
              isTrue);
        }
      }
    }
  });

  test('zoom preserves marks', () {
    final controller = FractalController(registry)
      ..selectModule(module(), animate: false);
    addTearDown(controller.dispose);
    controller.updateParam('marks', 1);
    controller.updateZoom(32);
    expect(controller.view.zoom, 32);
    expect(controller.params['marks'], 1);
  });
}
