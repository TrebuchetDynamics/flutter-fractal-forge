import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu/formulas/cpu_formulas.dart';
import 'package:flutter_fractals/features/viewer/rendering/cpu_fallback_pane.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _id = 'zeta_critical_strip';
const _asset = 'shaders/number_theory/zeta_critical_strip_gpu.frag';
const _zeroHeights = [
  14.134725142,
  21.022039639,
  25.010857580,
  30.424876126,
  32.935061588,
  37.586178159,
  40.918719012,
  43.327073281,
  48.005150881,
  49.773832478,
];
const _weights = [
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -1.0,
  -0.9999999999999992,
  -0.9999999999999852,
  -0.9999999999997845,
  -0.9999999999973079,
  -0.9999999999710746,
  -0.999999999730425,
  -0.9999999978052279,
  -0.9999999842921771,
  -0.9999999006381278,
  -0.9999994418278422,
  -0.999997203728888,
  -0.9999874611374572,
  -0.9999495073899707,
  -0.999816871155403,
  -0.9994002309671448,
  -0.998221949891754,
  -0.995218197716334,
  -0.9883095677128683,
  -0.9739656970704641,
  -0.9470770175272452,
  -0.9015752858835114,
  -0.8321038920345966,
  -0.7364957080523137,
  -0.6180557189399335,
  -0.48622686149311023,
  -0.35470746145813403,
  -0.2374550677949638,
  -0.14439369429808976,
  -0.07894393711347507,
  -0.03838994199718532,
  -0.016409456839304695,
  -0.006081277066324643,
  -0.0019217474833351398,
  -0.0005069858540111238,
  -0.00010852115541499642,
  -1.8090800979659343e-05,
  -2.2018711680970302e-06,
  -1.7394196846341903e-07,
  -6.690075710131501e-09,
];

List<double> _regenerateWeights() {
  const n = 50;
  final factorials = [BigInt.one];
  for (var i = 1; i <= 2 * n; i++) {
    factorials.add(factorials.last * BigInt.from(i));
  }
  final d = <BigInt>[];
  var sum = BigInt.zero;
  for (var i = 0; i <= n; i++) {
    sum += BigInt.from(n) *
        factorials[n + i - 1] *
        (BigInt.one << (2 * i)) ~/
        (factorials[n - i] * factorials[2 * i]);
    d.add(sum);
  }
  return [for (final dk in d.take(n)) (dk - d.last) / d.last];
}

// Independent double-precision reference for the shader's Borwein sum and
// Lanczos functional equation. The sample points below avoid the eta quotient's
// removable singularities and do not need the shader's float32 safeguards.
class _Complex {
  const _Complex(this.parts);
  final (double, double) parts;
  double get re => parts.$1;
  double get im => parts.$2;
  double get modulus => math.sqrt(re * re + im * im);
  _Complex operator +(_Complex b) => _Complex((re + b.re, im + b.im));
  _Complex operator -(_Complex b) => _Complex((re - b.re, im - b.im));
  _Complex operator *(_Complex b) =>
      _Complex((re * b.re - im * b.im, re * b.im + im * b.re));
  _Complex operator /(_Complex b) =>
      (this * _Complex((b.re, -b.im))).scale(1 / (b.re * b.re + b.im * b.im));
  _Complex scale(double a) => _Complex((a * re, a * im));
  _Complex exp() => _Complex((math.cos(im), math.sin(im))).scale(math.exp(re));
  _Complex log() => _Complex((math.log(modulus), math.atan2(im, re)));
  _Complex sin() => _Complex((
        math.sin(re) * (math.exp(im) + math.exp(-im)) / 2,
        math.cos(re) * (math.exp(im) - math.exp(-im)) / 2
      ));
}

_Complex _gamma(_Complex s) {
  const p = [
    0.99999999999980993,
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7,
  ];
  final z = s - const _Complex((1, 0));
  var sum = _Complex((p.first, 0));
  for (var i = 1; i < p.length; i++) {
    sum += _Complex((p[i], 0)) / (z + _Complex((i.toDouble(), 0)));
  }
  final t = z + const _Complex((7.5, 0));
  return ((z + const _Complex((.5, 0))) * t.log() - t).exp() *
      sum.scale(math.sqrt(2 * math.pi));
}

_Complex _zeta(_Complex s) {
  final oneMinusS = const _Complex((1, 0)) - s;
  if (s.re < .5) {
    return (s.scale(math.ln2) - oneMinusS.scale(math.log(math.pi))).exp() *
        s.scale(math.pi / 2).sin() *
        _gamma(oneMinusS) *
        _zeta(oneMinusS);
  }
  var sum = const _Complex((0, 0));
  for (var k = 0; k < _weights.length; k++) {
    sum += s
        .scale(-math.log(k + 1))
        .exp()
        .scale(k.isEven ? -_weights[k] : _weights[k]);
  }
  return sum / (const _Complex((1, 0)) - oneMinusS.scale(math.ln2).exp());
}

// Inverse of the module's documented transform at its default camera.
ui.Offset _pixel(ui.Size size, double real, double imaginary) {
  final scale = math.min(size.width, size.height) / 29;
  return size.center(ui.Offset.zero) +
      ui.Offset(real - .5, 25 - imaginary) * scale;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();
  FractalModule module() => registry.modules.singleWhere((m) => m.id == _id);

  test('one static Number Theory entry with phase bands and guides', () {
    final entry = CatalogRepository.fromRegistry(registry)
        .entries
        .singleWhere((e) => e.module.id == _id);
    expect(entry.category, 'Number Theory');
    expect(module().displayName(AppLocalizationsEn()),
        'Riemann Zeta Critical Strip');
    expect(entry.mathematics.method,
        'Borwein accelerated eta series with functional equation');
    expect(entry.mathematics.qualification, contains('not a proof'));
    expect(module().shaderAsset, _asset);
    expect(module().animationCapability, FractalAnimationCapability.static);
    final parameters = module().parameters;
    expect(parameters.map((p) => p.id), ['contours', 'guides']);
    expect(parameters.first.resolvedControl, FractalParamControl.chips);
    expect(parameters.last.resolvedControl, FractalParamControl.toggle);
    expect(module().defaultPreset.params, {'contours': 1, 'guides': true});
  });

  testWidgets('CPU fallback does not display or export a synthetic substitute',
      (tester) async {
    expect(() => cpuFormulaForModuleId(_id), throwsUnsupportedError);
    final controller = FractalController(registry)
      ..selectModule(module(), animate: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CpuFallbackPane(boundaryKey: GlobalKey())),
      ),
    ));
    expect(find.textContaining('Switch to the GPU renderer'), findsOneWidget);
    expect(find.byType(CpuFractalRenderer), findsNothing);
  });

  test('shader and reference weights match Borwein’s definition', () {
    final matches = RegExp(r'w\[(\d+)\]\s*=\s*([^;]+);')
        .allMatches(File(_asset).readAsStringSync());
    expect(matches.map((m) => int.parse(m[1]!)), List.generate(50, (i) => i));
    expect(matches.map((m) => double.parse(m[2]!)), _weights);
    expect(_weights, _regenerateWeights());
  });

  test('reference agrees with positive and negative real values', () {
    for (final (s, expected) in [
      (2.0, math.pi * math.pi / 6),
      (3.0, 1.2020569032),
      (.5, -1.4603545088),
      (-1.0, -1 / 12),
      (-3.0, 1 / 120),
      (-2.0, 0.0),
      (10.0, 1.0009945751278),
    ]) {
      expect((_zeta(_Complex((s, 0))) - _Complex((expected, 0))).modulus,
          lessThan(1e-9),
          reason: 'ζ($s)');
    }
  });

  test('the first ten non-trivial zeros agree with Odlyzko’s heights', () {
    for (final height in _zeroHeights) {
      expect(_zeta(_Complex((.5, height))).modulus, lessThan(1e-6),
          reason: 'ζ(1/2 + ${height}i)');
    }
  });

  test('default camera fits ten portrait zeros and six landscape zeros', () {
    final view = module().defaultPreset.view;
    expect(view.zoom, 1);
    expect(view.pan.length, 0);
    for (final (size, count) in [
      (const ui.Size(1080, 1920), 10),
      (const ui.Size(1920, 1080), 6),
    ]) {
      final viewport = ui.Offset.zero & size;
      expect(_pixel(size, .5, 25), viewport.center);
      expect(_pixel(size, 1.5, 25).dx - viewport.center.dx,
          closeTo(viewport.center.dy - _pixel(size, .5, 26).dy, 1e-10));
      expect(_zeroHeights.where((y) => viewport.contains(_pixel(size, .5, y))),
          _zeroHeights.take(count));
    }
  });

  test('shader compiles, renders phase and clips beyond the window', () async {
    final program = await ui.FragmentProgram.fromAsset(module().shaderAsset);
    const size = ui.Size(290, 520);
    Future<List<List<int>>> samples(
        {required int contours, required bool guides}) async {
      final shader = program.fragmentShader();
      module().setUniforms(
          shader,
          FractalRenderState(
            params: {'contours': contours, 'guides': guides},
            transparentBackground: false,
            view: module().defaultPreset.view,
          ),
          size,
          0);
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
          .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final bytes = (await image.toByteData())!;
      final colors = <List<int>>[];
      for (final (x, y) in [
        (-12.0, 25.0),
        (12.0, 25.0),
        (.25, 25.0),
        (.75, 25.0),
        (.5, 25.0),
        (-7.0, 49.0),
        (.5, 50.5)
      ]) {
        final point = _pixel(size, x, y);
        final index =
            (point.dy.floor() * size.width.toInt() + point.dx.floor()) * 4;
        colors.add(
            List.generate(3, (channel) => bytes.getUint8(index + channel)));
      }
      image.dispose();
      picture.dispose();
      shader.dispose();
      return colors;
    }

    final phase = await samples(contours: 0, guides: false);
    expect(phase[0].toSet(), hasLength(1)); // Neutral background.
    expect(phase[1], phase[0]);
    expect(phase[6], phase[0]);
    expect(phase[2], isNot(phase[3])); // Opposite sides of the zero.
    expect(
        phase[5].toSet(), hasLength(greaterThan(1))); // Reflection at high t.
    final bands = await samples(contours: 1, guides: false);
    expect(bands[2], isNot(phase[2]));
    final guided = await samples(contours: 1, guides: true);
    expect(guided[4].reduce((a, b) => a + b),
        greaterThan(bands[4].reduce((a, b) => a + b)));
  });
}
