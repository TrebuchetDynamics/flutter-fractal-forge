import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/controllers/params/fractal_param_value_normalizer.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';

void main() {
  test('sampler shader compiles as a Flutter runtime effect', () async {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/number_theory/number_wall_gpu.frag',
    );
    expect(program, isNotNull);
  });

  test('sampler shader pans and zooms within the sampled grid', () async {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/number_theory/number_wall_gpu.frag',
    );
    final pixels = Uint8List.fromList([
      255,
      0,
      0,
      255,
      0,
      255,
      0,
      255,
      0,
      0,
      255,
      255,
      255,
      255,
      255,
      255,
    ]);
    final decoded = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      4,
      1,
      ui.PixelFormat.rgba8888,
      decoded.complete,
    );
    final texture = await decoded.future;
    addTearDown(texture.dispose);

    Future<Uint8List> render(ui.Rect rect) async {
      final shader = program.fragmentShader()
        ..setFloat(0, 4)
        ..setFloat(1, 1)
        ..setFloat(2, 4)
        ..setFloat(3, 1)
        ..setFloat(4, rect.left)
        ..setFloat(5, rect.top)
        ..setFloat(6, rect.width)
        ..setFloat(7, rect.height)
        ..setImageSampler(0, texture);
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawRect(rect, ui.Paint()..shader = shader);
      final picture = recorder.endRecording();
      try {
        final image = await picture.toImage(4, 1);
        try {
          final byteData =
              (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
          return byteData.buffer.asUint8List();
        } finally {
          image.dispose();
          shader.dispose();
        }
      } finally {
        picture.dispose();
      }
    }

    final untransformed = await render(const ui.Rect.fromLTWH(0, 0, 4, 1));
    final zoomed = await render(const ui.Rect.fromLTWH(-2, 0, 8, 1));
    expect(untransformed.take(4), [255, 0, 0, 255]);
    expect(zoomed.take(4), [0, 255, 0, 255]);
  });

  test('registers one Number Walls entry and preserves decimal moduli exactly',
      () {
    const prime = '170141183460469231731687303715884105727';
    final registry = ModuleRegistry();
    final module = registry.byId('number_wall');
    final entry = CatalogRepository.fromRegistry(registry)
        .entries
        .singleWhere((entry) => entry.module.id == 'number_wall');
    final modulus =
        module.parameters.singleWhere((param) => param.id == 'prime');
    final value = normalizeFractalParamValue(modulus, prime);
    final preset = FractalPreset(
      id: 'custom',
      moduleId: module.id,
      name: 'Custom modulus',
      params: {'prime': value},
      view: module.defaultPreset.view,
      createdAt: DateTime.utc(2026),
    );
    final restored = FractalPreset.fromJson(preset.toJson());

    expect(module.id, 'number_wall');
    expect(entry.catalogId, 'core.number_wall');
    expect(entry.category, 'Number Walls');
    expect(modulus.type, FractalParamType.decimalInteger);
    expect(value, prime);
    expect(restored.params['prime'], prime);
  });
}
