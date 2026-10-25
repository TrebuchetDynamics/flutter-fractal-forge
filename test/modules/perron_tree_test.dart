import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/rendering/cpu_fallback_pane.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/perron_tree_model.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

bool inside(double x, double y, PerronTree tree, double angle) {
  for (var fan = 0; fan < 3; fan++) {
    final a = -(angle * math.pi / 180 + fan * 2 * math.pi / 3);
    final px = x * math.cos(a) - y * math.sin(a),
        py = x * math.sin(a) + y * math.cos(a) + tree.centerY;
    for (var i = 0; i < tree.leafCount; i++) {
      final ox = tree.offsets[i] + tree.centerX, h = PerronTree.halfBase;
      final vertices = [
        (ox, 0.0),
        (ox - h + 2 * h * i / tree.leafCount, 1.0),
        (ox - h + 2 * h * (i + 1) / tree.leafCount, 1.0)
      ];
      final cross = <double>[];
      for (var j = 0; j < 3; j++) {
        final u = vertices[j], v = vertices[(j + 1) % 3];
        cross.add((v.$1 - u.$1) * (py - u.$2) - (v.$2 - u.$2) * (px - u.$1));
      }
      if (cross.every((v) => v >= 0) || cross.every((v) => v <= 0)) return true;
    }
  }
  return false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final module = ModuleRegistry().byId('perron_tree');
  Future<ui.Image> draw(Map<String, Object> params,
      {int width = 240,
      int height = 200,
      bool transparent = false,
      FractalViewState? view,
      double time = 0}) async {
    final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
    final shader = program.fragmentShader();
    final size = ui.Size(width.toDouble(), height.toDouble());
    module.setUniforms(
        shader,
        FractalRenderState(
            params: params,
            view: view ?? module.defaultPreset.view,
            transparentBackground: transparent),
        size,
        time);
    final recorder = ui.PictureRecorder(), canvas = ui.Canvas(recorder);
    canvas.drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    shader.dispose();
    return image;
  }

  test('CPU dispatch refuses synthetic substitution', () {
    expect(hasNativeCpuFormula('perron_tree'), isFalse);
    expect(() => cpuFormulaForModuleId('perron_tree'), throwsUnsupportedError);
  });
  testWidgets('CPU-only viewer explains its limitation in EN and ES',
      (tester) async {
    final controller = FractalController(ModuleRegistry())
      ..selectModule(module, animate: false);
    addTearDown(controller.dispose);
    for (final code in ['en', 'es']) {
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: Locale(code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CpuFallbackPane(boundaryKey: GlobalKey())),
          )));
      await tester.pumpAndSettle();
      expect(
          find.textContaining(
              code == 'en' ? 'no substitute image' : 'imagen sustituta'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  test('one finite Perron tree identity and honest static metadata', () {
    expect(ModuleRegistry().modules.where((m) => m.id == 'perron_tree'),
        hasLength(1));
    expect(module.animationCapability, FractalAnimationCapability.static);
    final math = FractalMathematics.forModule(module);
    expect(math.family, 'IFS and geometric constructions');
    expect(math.qualification, contains('not a zero-area'));
    expect(module.builtInPresets, hasLength(2));
  });
  test('decoded shader PNG coverage agrees with independent barycentric oracle',
      () async {
    for (final depth in [0, 3, 5]) {
      final params = {
        ...module.defaultPreset.params,
        'depth': depth.toDouble(),
        'style': 0.0,
        'glow': 0.0,
        'angle': 23.0
      };
      final image = await draw(params);
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      final decoded = img.decodePng(png.buffer.asUint8List())!;
      expect([decoded.width, decoded.height], [240, 200]);
      final tree = PerronTree(depth: depth, overlap: .8);
      const scale = 3 / (200 * 1.25);
      var checked = 0, hits = 0;
      for (var y = 3; y < 197; y += 3) {
        for (var x = 3; x < 237; x += 3) {
          final px = (x + .5 - 120) * scale, py = (y + .5 - 100) * scale;
          final expected = inside(px, py, tree, 23);
          final stable = [
            for (final dx in [-3, 3])
              for (final dy in [-3, 3])
                inside(px + dx * scale, py + dy * scale, tree, 23)
          ].every((v) => v == expected);
          if (!stable) continue;
          final green = decoded.getPixel(x, y).g.toInt();
          // An antialiased outside edge may contribute up to half of the
          // geometric green channel (204); do not call that an interior pixel.
          expect(green > 115, expected,
              reason: 'd=$depth x=$x y=$y green=$green');
          checked++;
          if (expected) hits++;
        }
      }
      expect(checked, greaterThan(500));
      expect(hits, greaterThan(10));
      image.dispose();
    }
  });
  test('luminous overlap retains color instead of clipping its center',
      () async {
    for (final depth in [0, 3, 5]) {
      for (final glow in [.7, 1.0]) {
        final image = await draw(
            {...module.defaultPreset.params, 'depth': depth, 'glow': glow});
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final channels = [
          for (var c = 0; c < 3; c++) bytes.getUint8((100 * 240 + 120) * 4 + c)
        ];
        expect(channels.reduce(math.max), lessThan(240),
            reason: 'depth=$depth glow=$glow center=$channels');
        expect(channels.reduce(math.min), greaterThan(32));
        image.dispose();
      }
    }
  });
  test('style, rotation, transparent PNG and captured state are real output',
      () async {
    final captured = Map<String, Object>.of(module.defaultPreset.params);
    final geometric = await draw({...captured, 'style': 0.0});
    final luminous = await draw(captured);
    final transparent = await draw(captured, transparent: true);
    final before =
        (await luminous.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
    final flat =
        (await geometric.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
    expect(before, isNot(orderedEquals(flat)));
    final trans =
        (await transparent.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    expect(trans.getUint8(3), 0);
    final again = await draw(captured, time: 12);
    expect(
        (await again.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List(),
        orderedEquals(before));
    final png = (await transparent.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    expect(png.take(8), orderedEquals([137, 80, 78, 71, 13, 10, 26, 10]));
    final dir = kIsWeb ? null : Platform.environment['PERRON_PREVIEW_DIR'];
    if (dir != null) {
      Directory(dir).createSync(recursive: true);
      final showcase = await draw(captured, width: 960, height: 720);
      File('$dir/perron-tree.png').writeAsBytesSync(
          (await showcase.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List());
      showcase.dispose();
      final timings = <String, List<int>>{};
      for (final depth in [0, 3, 5]) {
        final samples = <int>[];
        for (var sample = 0; sample < 3; sample++) {
          final watch = Stopwatch()..start();
          final frame = await draw({...captured, 'depth': depth},
              width: 512, height: 512);
          await frame.toByteData(format: ui.ImageByteFormat.rawRgba);
          watch.stop();
          samples.add(watch.elapsedMicroseconds);
          frame.dispose();
        }
        timings['$depth'] = samples;
      }
      File('$dir/host-draw-timings.json').writeAsStringSync(jsonEncode({
        'backend': 'Flutter test host raster; hardware GPU unqualified',
        'size': [512, 512],
        'metric':
            'program lookup, shader creation, draw, image creation and RGBA readback microseconds',
        'depth_samples': timings
      }));
      for (final pair in [
        ('geometric', geometric),
        ('luminous', luminous),
        ('transparent', transparent)
      ]) {
        File('$dir/${pair.$1}.png').writeAsBytesSync(
            (await pair.$2.toByteData(format: ui.ImageByteFormat.png))!
                .buffer
                .asUint8List());
      }
    }
    for (final image in [geometric, luminous, transparent, again]) {
      image.dispose();
    }
  });
  test('transparent luminous output composites over the same background',
      () async {
    final params = {
      ...module.defaultPreset.params,
      'angle': 27.0,
      'hue': .25,
      'glow': 1.0
    };
    final opaque = await draw(params);
    final transparent = await draw(params, transparent: true);
    final a = (await opaque.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final b =
        (await transparent.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    var maxError = 0.0;
    const background = [.012, .018, .035];
    for (var offset = 0; offset < a.lengthInBytes; offset += 4) {
      final alpha = b.getUint8(offset + 3) / 255;
      for (var c = 0; c < 3; c++) {
        expect(
            b.getUint8(offset + c), lessThanOrEqualTo(b.getUint8(offset + 3)));
        final expected =
            b.getUint8(offset + c) + 255 * background[c] * (1 - alpha);
        maxError =
            math.max(maxError, (a.getUint8(offset + c) - expected).abs());
      }
    }
    expect(maxError, lessThanOrEqualTo(2));
    opaque.dispose();
    transparent.dispose();
  });
  test('legal extreme zoom and malformed parameters do not fill the background',
      () async {
    for (final zoom in [1e-9, 1e12]) {
      final image = await draw({
        'depth': double.nan,
        'overlap': double.infinity,
        'angle': double.nan,
        'glow': double.nan,
        'style': double.nan
      },
          view: module.defaultPreset.view
              .copyWith(zoom: zoom, pan: Vector2(100, 100)),
          transparent: true,
          width: 32,
          height: 32);
      final data =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      expect(data.getUint8(3), 0);
      image.dispose();
    }
  });
}
