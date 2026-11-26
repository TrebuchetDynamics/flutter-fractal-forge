import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = 'recaman_arcs';
const _asset = 'shaders/number_theory/recaman_arcs_gpu.frag';

List<int> _sequence() {
  final terms = [0];
  final seen = {0};
  for (var n = 1; n <= 128; n++) {
    final back = terms.last - n;
    final next = back > 0 && !seen.contains(back) ? back : terms.last + n;
    terms.add(next);
    seen.add(next);
  }
  return terms;
}

// Invert the documented number-plane transform at the default camera.
ui.Offset _pixel(ui.Size size, double x, double y) {
  final scale = math.min(size.width / 128, size.height / 76);
  return size.center(ui.Offset.zero) + ui.Offset(x - 57, -y) * scale;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();
  FractalModule module() => registry.byId(_id);

  test('one static Number Theory entry with only the intended controls', () {
    expect(registry.modules.where((m) => m.id == _id), hasLength(1));
    final entry = CatalogRepository.fromRegistry(registry)
        .entries
        .singleWhere((e) => e.module.id == _id);
    expect(entry.category, 'Number Theory');
    expect(module().displayName(AppLocalizationsEn()), "Recamán's Sequence");
    expect(entry.mathematics.method, 'Arc diagram of OEIS A005132');
    expect(entry.mathematics.qualification,
        contains('not a self-similar fractal'));
    expect(module().shaderAsset, _asset);
    expect(module().animationCapability, FractalAnimationCapability.static);
    final parameters = module().parameters;
    expect(parameters.map((p) => p.id),
        ['terms', 'lineWidth', 'layout', 'colorScheme']);
    expect(parameters[0].type, FractalParamType.integer);
    expect((parameters[0].min, parameters[0].max, parameters[0].defaultValue),
        (8, 128, 64));
    expect((parameters[1].min, parameters[1].max, parameters[1].defaultValue),
        (.5, 4, 1.5));
    expect(parameters[2].resolvedControl, FractalParamControl.chips);
    expect(parameters[2].options.map((o) => o.value), [0, 1]);
    expect(parameters[2].defaultValue, 0);
  });

  test('all 129 shader assignments match OEIS A005132', () {
    final sequence = _sequence();
    expect(sequence.take(12), [0, 1, 3, 6, 2, 7, 13, 20, 12, 21, 11, 22]);
    final source = File(_asset).readAsStringSync();
    final matches =
        RegExp(r'T\[(\d+)\]\s*=\s*(\d+)\.0;').allMatches(source).toList();
    expect(matches.map((m) => int.parse(m[1]!)), List.generate(129, (i) => i));
    expect(matches.map((m) => int.parse(m[2]!)), sequence);
  });

  test('default diagram bounds fit in landscape and portrait', () {
    final view = module().defaultPreset.view;
    expect(view.zoom, 1);
    expect(view.pan.length, 0);
    expect(_sequence().take(65).reduce(math.max), 114);
    for (final size in [const ui.Size(1920, 1080), const ui.Size(1080, 1920)]) {
      final viewport = ui.Offset.zero & size;
      for (final x in [0.0, 114.0]) {
        for (final y in [-32.0, 32.0]) {
          expect(viewport.contains(_pixel(size, x, y)), isTrue);
        }
      }
    }
  });

  test('zoom does not change the selected term count', () {
    final controller = FractalController(registry)
      ..selectModule(module(), animate: false);
    addTearDown(controller.dispose);
    controller.updateParam('terms', 37);
    controller.updateZoom(32);
    expect(controller.view.zoom, 32);
    expect(controller.params['terms'], 37);
  });

  test('shader draws the eighth arc below the axis or above with layout',
      () async {
    final program = await ui.FragmentProgram.fromAsset(module().shaderAsset);
    const size = ui.Size(512, 304);
    Future<int> alphaAt(double y,
        {double x = 16,
        required int terms,
        int layout = 0,
        double width = 1.5}) async {
      final shader = program.fragmentShader();
      module().setUniforms(
          shader,
          FractalRenderState(
            params: {
              ...module().defaultPreset.params,
              'terms': terms,
              'layout': layout,
              'lineWidth': width
            },
            view: module().defaultPreset.view,
            transparentBackground: true,
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
      // Step 8 joins 20 and 12: center 16, radius 4.
      final tip = _pixel(size, x, y);
      final alpha = bytes.getUint8(
          (tip.dy.floor() * size.width.toInt() + tip.dx.floor()) * 4 + 3);
      image.dispose();
      picture.dispose();
      shader.dispose();
      return alpha;
    }

    expect(await alphaAt(-4, terms: 8), greaterThan(170));
    expect(await alphaAt(4, terms: 8), 0);
    expect(await alphaAt(-4, terms: 8, layout: 1), 0);
    expect(await alphaAt(4, terms: 8, layout: 1), greaterThan(170));
    // Step 9 (12 to 21) adds the tip at (16.5, 4.5) above the axis.
    expect(await alphaAt(4.5, x: 16.5, terms: 8), 0);
    expect(await alphaAt(4.5, x: 16.5, terms: 9), greaterThan(170));
    expect(await alphaAt(-4.25, terms: 8, width: .5), 0);
    expect(await alphaAt(-4.25, terms: 8, width: 4), greaterThan(170));
  });
}
