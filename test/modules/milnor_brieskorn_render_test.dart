import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/rendering/cpu_fallback_pane.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;
import '../helpers/milnor_brieskorn_oracle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final module = ModuleRegistry().byId('milnor_brieskorn');
  Future<ui.Image> draw(
      {Map<String, Object>? params,
      FractalViewState? view,
      int width = 160,
      int height = 120,
      bool transparent = true,
      double time = 0,
      bool rawInvalid = false}) async {
    final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
    final shader = program.fragmentShader();
    final size = ui.Size(width.toDouble(), height.toDouble());
    module.setUniforms(
        shader,
        FractalRenderState(
            params: params ?? module.defaultPreset.params,
            view: view ?? module.defaultPreset.view,
            transparentBackground: transparent),
        size,
        time);
    if (rawInvalid) {
      for (final slot in [0, 3, 4, 5, 6, 7, 8]) {
        shader.setFloat(slot, double.nan);
      }
    }
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
        .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    shader.dispose();
    return image;
  }

  Future<List<int>> rgba(ui.Image image) async =>
      (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List();

  test('binomial exact orbit fixtures and analytic escape lower bound', () {
    for (final c in [(0.0, 0.0), (-1.0, 0.0)]) {
      var z = (0.0, 0.0);
      for (var n = 0; n < 20; n++) {
        z = orbitStep(z, c);
        expect(z, c.$1 == 0 || n.isOdd ? (0.0, 0.0) : (-1.0, 0.0));
      }
    }
    expect(orbitStep((1, 1), (0, 0)), (-6.0, 4.0));
    var real = (0.0, 0.0);
    for (final expected in [1.0, 6.0, 8101.0]) {
      real = orbitStep(real, (1, 0));
      expect(real, (expected, 0.0));
    }
    var z = orbitStep((0, 0), (0, 1));
    expect(z, (0.0, 1.0));
    z = orbitStep(z, (0, 1));
    expect(z, (-3.0, 1.0));
    z = orbitStep(z, (0, 1));
    expect(z, (18.0, 325.0));
    for (final c in [0.0, .1, 1.0, 10.0, 1e9, 1e20]) {
      for (final bailout in [2.0, 4.0, 8.0]) {
        final r = escapeRadius(c, 0, bailout);
        expect(r, greaterThanOrEqualTo(bailout));
        expect(r * r * r * r * r / 4, greaterThan(r));
        expect(r * r * r, greaterThanOrEqualTo(12 - 1e-10));
        expect(r * r * r * r * r, greaterThanOrEqualTo(4 * c * (1 - 1e-14)));
        // Independent triangle-inequality lower bound, r^5-r^3-3r^2-|c| > r.
        expect(math.pow(r, 5) - math.pow(r, 3) - 3 * r * r - c, greaterThan(r));
      }
    }
  });

  test(
      'production fragment escape mask agrees with binomial oracle including boundary margins',
      () async {
    var checked = 0, interior = 0, exterior = 0, nearBoundary = 0;
    for (final view in [
      module.defaultPreset.view,
      module.builtInPresets.last.view
    ]) {
      final image = await draw(view: view);
      final data = await rgba(image);
      final scale = 1 / (120 * view.zoom);
      for (var y = 1; y < 119; y += 2) {
        for (var x = 1; x < 159; x += 2) {
          final cx = (x + .5 - 80) * scale + view.pan.x;
          final cy = (y + .5 - 60) * scale + view.pan.y;
          final n = (module.defaultPreset.params['iterations'] as num).toInt();
          final expected = escaped(cx, cy, n);
          // Explicit margin, not relaxed alpha threshold: compare four nearby points.
          final stable = [
            for (final dx in [-.08, .08])
              for (final dy in [-.08, .08])
                escaped(cx + dx * scale, cy + dy * scale, n)
          ].every((v) => v == expected);
          if (!stable) continue;
          final boundary = [
            for (final dx in [-2.0, 2.0])
              for (final dy in [-2.0, 2.0])
                escaped(cx + dx * scale, cy + dy * scale, n)
          ].any((v) => v != expected);
          expect(data[(y * 160 + x) * 4 + 3], expected ? 255 : 0,
              reason: 'x=$x y=$y c=($cx,$cy), zoom=${view.zoom}');
          checked++;
          if (expected) {
            exterior++;
          } else {
            interior++;
          }
          if (boundary) nearBoundary++;
        }
      }
      image.dispose();
    }
    expect(checked, greaterThan(5000));
    expect(interior, greaterThan(100));
    expect(exterior, greaterThan(100));
    expect(nearBoundary, greaterThan(50));
    print(
        'oracle classified=$checked interior=$interior exterior=$exterior nearBoundary=$nearBoundary; margin=0.08 pixel');
  });

  test(
      'small bailout cannot falsely escape exact cycle and Nth update is tested',
      () async {
    for (final c in [(0.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (1.0, 0.0)]) {
      for (final n in [0, 1, 2, 3, 20, 500]) {
        final image = await draw(
            width: 1,
            height: 1,
            params: {'iterations': n, 'bailout': 2.0, 'colorScheme': 1},
            view: module.defaultPreset.view
                .copyWith(pan: Vector2(c.$1, c.$2), zoom: 1e12));
        final bytes = await rgba(image);
        expect(bytes[3], escaped(c.$1, c.$2, n, 2) ? 255 : 0,
            reason: 'c=$c n=$n');
        image.dispose();
      }
    }
    expect(module.parameters.firstWhere((p) => p.id == 'iterations').max, 500);
  });

  test('all 64 palettes, transparency premultiplication and state roundtrip',
      () async {
    final distinct = <String>{};
    for (var scheme = 0; scheme < 64; scheme++) {
      final preset = module.defaultPreset.copyWith(
          params: {...module.defaultPreset.params, 'colorScheme': scheme});
      final restored =
          FractalPreset.fromJson(jsonDecode(jsonEncode(preset.toJson())));
      expect(restored.toJson(), preset.toJson());
      final transparent = await draw(
          params: restored.params, view: restored.view, width: 32, height: 24);
      final opaque = await draw(
          params: restored.params,
          view: restored.view,
          width: 32,
          height: 24,
          transparent: false);
      final a = await rgba(transparent), b = await rgba(opaque);
      distinct.add(base64Encode(a));
      for (var i = 0; i < a.length; i += 4) {
        expect(a[i + 3], anyOf(0, 255));
        expect(b[i + 3], 255);
        for (var channel = 0; channel < 3; channel++) {
          expect(a[i + channel], lessThanOrEqualTo(a[i + 3]));
          if (a[i + 3] == 255)
            expect(a[i + channel], b[i + channel]);
          else
            expect(a[i + channel],
                0); // transparent interior composites to its opaque interior.
        }
      }
      transparent.dispose();
      opaque.dispose();
    }
    expect(distinct.length, greaterThan(55));
  });

  test('transparent shader readback composites over a known background',
      () async {
    final image = await draw(width: 160, height: 120);
    final a = await rgba(image);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawColor(const ui.Color(0xFF204080), ui.BlendMode.src);
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());
    final picture = recorder.endRecording();
    final composite = await picture.toImage(160, 120);
    final b = await rgba(composite);
    var clear = 0, solid = 0;
    for (var i = 0; i < a.length; i += 4) {
      final alpha = a[i + 3] / 255;
      for (var k = 0; k < 3; k++) {
        final expected = a[i + k] + [32, 64, 128][k] * (1 - alpha);
        expect((b[i + k] - expected).abs(), lessThanOrEqualTo(1));
      }
      expect(b[i + 3], 255);
      if (alpha == 0)
        clear++;
      else
        solid++;
    }
    expect(clear, greaterThan(100));
    expect(solid, greaterThan(100));
    picture.dispose();
    image.dispose();
    composite.dispose();
  });

  test(
      'large inputs, legal zoom extremes and invalid raw uniforms render safely',
      () async {
    for (final zoom in [1e-9, 1e12]) {
      for (final center in [0.0, -1.0, 1e9, 1e20, 2.9e38]) {
        final image = await draw(
            width: 1,
            height: 1,
            view: module.defaultPreset.view
                .copyWith(pan: Vector2(center, 0), zoom: zoom));
        expect((await rgba(image))[3], center.abs() > 2 ? 255 : 0);
        image.dispose();
      }
    }
    final invalid = await draw(width: 16, height: 12, rawInvalid: true);
    final canonical = await draw(
        width: 16,
        height: 12,
        params: {'iterations': 400, 'bailout': 4.0, 'colorScheme': 1},
        view: module.defaultPreset.view
            .copyWith(pan: Vector2(-.35, 0), zoom: .4));
    expect(await rgba(invalid), orderedEquals(await rgba(canonical)));
    invalid.dispose();
    canonical.dispose();
  });

  test('actual 960x720 previews and exact replay states', () async {
    final dir = kIsWeb ? null : Platform.environment['MILNOR_PREVIEW_DIR'];
    for (final preset in module.builtInPresets) {
      final image = await draw(
          width: 960,
          height: 720,
          params: preset.params,
          view: preset.view,
          transparent: false);
      final bytes = await rgba(image);
      expect(bytes.toSet().length, greaterThan(80));
      if (dir != null) {
        Directory(dir).createSync(recursive: true);
        File('$dir/${preset.id}.png').writeAsBytesSync(
            (await image.toByteData(format: ui.ImageByteFormat.png))!
                .buffer
                .asUint8List());
        File('$dir/${preset.id}.json')
            .writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
          'preset': preset.toJson(),
          'width': 960,
          'height': 720,
          'time': 0,
          'transparentBackground': false,
          'backend':
              'Flutter FragmentProgram host readback; not hardware GPU evidence'
        }));
      }
      final later = await draw(
          width: 32,
          height: 24,
          params: preset.params,
          view: preset.view,
          time: 12);
      final first = await draw(
          width: 32, height: 24, params: preset.params, view: preset.view);
      expect(await rgba(later), orderedEquals(await rgba(first)));
      image.dispose();
      first.dispose();
      later.dispose();
    }
  });

  testWidgets('EN and ES CPU limitation and inspired metadata are visible',
      (tester) async {
    final controller = FractalController(ModuleRegistry())
      ..selectModule(module, animate: false);
    addTearDown(controller.dispose);
    for (final lang in ['en', 'es']) {
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                  body: Column(children: [
                Expanded(child: CpuFallbackPane(boundaryKey: GlobalKey())),
                FractalMathSummary(module: module)
              ])))));
      await tester.pumpAndSettle();
      expect(
          find.textContaining(
              lang == 'en' ? 'no substitute image' : 'imagen sustituta'),
          findsOneWidget);
      expect(
          find.textContaining(
              lang == 'en' ? 'not an exotic sphere' : 'no es una esfera'),
          findsOneWidget);
      expect(
          find.textContaining(lang == 'en'
              ? 'finite orbit of 0 only'
              : 'solo la órbita finita de 0'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
