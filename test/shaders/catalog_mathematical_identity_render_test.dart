import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();

  test('zero Life-like masks rasterize no birth or survival walls', () async {
    final pixels = await _render(
        registry.byId('life_like_b000_s000'),
        {
          'birthMask': 0.0,
          'survivalMask': 0.0,
        },
        transparent: false);
    final first = pixels.sublist(0, 4);
    for (var i = 0; i < pixels.length; i += 4) {
      expect(pixels.sublist(i, i + 4), first,
          reason: 'Empty masks must leave only the uniform background');
    }
    expect(first[3], 255);
  });

  test('Chebyshev default keeps the origin bounded in the compiled shader',
      () async {
    final module = registry.byId('f0166_chebyshev_julia');
    expect(module.defaultPreset.params['juliaCReal'], -2.0);
    final corrected = await _render(module, {});
    final legacy = await _render(module, {'juliaCReal': 2.0});
    const centerAlpha = (32 * 65 + 32) * 4 + 3;
    expect(corrected[centerAlpha], closeTo(217, 1),
        reason: 'The bounded critical orbit receives the interior alpha');
    expect(legacy[centerAlpha], 255,
        reason: 'z²+2 escapes and receives exterior alpha');
  });

  test('Cross and its legacy mode alias rasterize identical measurements',
      () async {
    final module = registry.byId('mandelbrot_orbit_trap');
    final cross = await _render(module, {'trapMode': 0.0});
    final alias = await _render(module, {'trapMode': 7.0});
    expect(alias, orderedEquals(cross));
  });
}

Future<Uint8List> _render(FractalModule module, Map<String, dynamic> overrides,
    {bool transparent = true}) async {
  const size = 65;
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  module.setUniforms(
    shader,
    FractalRenderState(
      params: {
        ...module.defaultPreset.params,
        'iterations': 32.0,
        'colorScheme': 0.0,
        ...overrides,
      },
      view: FractalViewState.initial(),
      transparentBackground: transparent,
    ),
    const ui.Size(65, 65),
    0,
  );
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 65, 65),
    ui.Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  try {
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    return Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  } finally {
    image.dispose();
    picture.dispose();
    shader.dispose();
  }
}
