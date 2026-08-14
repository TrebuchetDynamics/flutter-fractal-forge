import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Uint8List> _renderModuleAtTime(
  FractalModule module,
  double time, {
  bool transparentBackground = false,
  Map<String, Object>? params,
}) async {
  const size = ui.Size(96, 96);
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  final preset = module.defaultPreset;
  module.setUniforms(
    shader,
    FractalRenderState(
      params: params ?? preset.params,
      view: preset.view,
      transparentBackground: transparentBackground,
    ),
    size,
    time,
  );
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  shader.dispose();
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

int _countEnclosedDarkComponents(Uint8List pixels) {
  const width = 96;
  const height = 96;
  final dark = List<bool>.generate(width * height, (index) {
    final offset = index * 4;
    return pixels[offset] + pixels[offset + 1] + pixels[offset + 2] < 72;
  });
  final visited = List<bool>.filled(width * height, false);
  var enclosed = 0;

  for (var start = 0; start < dark.length; start++) {
    if (!dark[start] || visited[start]) continue;
    final pending = <int>[start];
    visited[start] = true;
    var area = 0;
    var touchesEdge = false;
    while (pending.isNotEmpty) {
      final index = pending.removeLast();
      final x = index % width;
      final y = index ~/ width;
      area++;
      touchesEdge |= x == 0 || y == 0 || x == width - 1 || y == height - 1;
      for (final neighbor in <int>[
        if (x > 0) index - 1,
        if (x + 1 < width) index + 1,
        if (y > 0) index - width,
        if (y + 1 < height) index + width,
      ]) {
        if (dark[neighbor] && !visited[neighbor]) {
          visited[neighbor] = true;
          pending.add(neighbor);
        }
      }
    }
    if (!touchesEdge && area >= 2) enclosed++;
  }
  return enclosed;
}

void main() {
  test('validated time-driven modules declare continuous animation', () {
    final registry = ModuleRegistry();

    for (final id in [
      'fractal_flame',
      'lichtenberg_growth',
      'gray_scott_rd',
      'mandelbulb_time_modulated',
      'quaternion_mandelbrot_3d',
      'kaleidoscope_basic',
      'kaleidoscope_rays',
      'kaleidoscope_mandala',
      'kaleidoscope_star',
      'kaleidoscope_snowflake',
      'kaleidoscope_flower',
      'kaleidoscope_jewel',
      'kaleidoscope_spiral',
      'kaleidoscope_geometric',
      'kaleidoscope_crystal',
      'kaleidoscope_wave',
      'kaleidoscope_fractal',
      'kaleidoscope_rosette',
      'kaleidoscope_ring',
      'kaleidoscope_nebula',
      'domain_coloring',
      'day_night',
      'highlife',
      'brian_brain',
      'f1020_brian_s_brain',
      'greenberg_hastings_ca',
      'cyclic_cellular_automaton',
      'gerhardt_schuster_tyson_ca',
      'tessarine_julia',
      'bicomplex',
      'dual_complex',
      'hypercomplex_newton',
      'quaternion_julia_2d',
      'bulbils',
      'cyclosorus_fern',
      'schottky_limit_set',
      'f1101_fractal_flame_v0_linear',
      'f1141_fractal_flame_v40_rectangles',
      'gauss_map',
      'tortoise_toroidal_fractal',
    ]) {
      expect(
        registry.byId(id).animationCapability,
        FractalAnimationCapability.timeDriven,
        reason: id,
      );
    }
  });

  test('perturb wrapper preserves declared animation metadata', () {
    const config = EscapeTimeConfig(
      id: 'burning_ship',
      name: 'Metadata Probe',
      shaderAsset: 'shaders/static_looking_probe.frag',
      animationCapability: FractalAnimationCapability.timeDriven,
    );
    final standardModule = buildEscapeTimeModule(config);

    final effectiveModule = buildEscapeTimePerturbModule(standardModule);

    expect(
      effectiveModule.animationCapability,
      FractalAnimationCapability.timeDriven,
    );
  });

  test('ordinary Mandelbrot is explicitly derived as static', () {
    expect(
      ModuleRegistry().byId('mandelbrot').animationCapability,
      FractalAnimationCapability.static,
    );
  });

  test('Quaternion Mandelbrot runtime output advances with elapsed time',
      () async {
    final module = ModuleRegistry().byId('quaternion_mandelbrot_3d');
    final first = await _renderModuleAtTime(module, 0);
    final second = await _renderModuleAtTime(module, 1.5);
    var differingPixels = 0;
    for (var offset = 0; offset < first.length; offset += 4) {
      if (first[offset] != second[offset] ||
          first[offset + 1] != second[offset + 1] ||
          first[offset + 2] != second[offset + 2] ||
          first[offset + 3] != second[offset + 3]) {
        differingPixels++;
      }
    }

    expect(differingPixels, greaterThan(0));
    expect(
      module.animationCapability,
      FractalAnimationCapability.timeDriven,
    );
  });

  test('TORTOISE advances visibly and keeps transparent misses premultiplied',
      () async {
    final module = ModuleRegistry().byId('tortoise_toroidal_fractal');
    final first = await _renderModuleAtTime(module, 0);
    // Runtime advances uTime by 1000 / 86400 per second.
    final second = await _renderModuleAtTime(module, 1000 / 86400);
    var differingPixels = 0;
    for (var offset = 0; offset < first.length; offset += 4) {
      if (first[offset] != second[offset] ||
          first[offset + 1] != second[offset + 1] ||
          first[offset + 2] != second[offset + 2]) {
        differingPixels++;
      }
    }
    expect(differingPixels, greaterThan(200));

    final transparent = await _renderModuleAtTime(
      module,
      0,
      transparentBackground: true,
    );
    var transparentPixels = 0;
    for (var offset = 0; offset < transparent.length; offset += 4) {
      if (transparent[offset + 3] == 0) {
        transparentPixels++;
        expect(
          transparent.sublist(offset, offset + 3),
          everyElement(0),
          reason: 'transparent pixels must use premultiplied zero RGB',
        );
      }
    }
    expect(transparentPixels, greaterThan(0));
  });

  test('TORTOISE preserves sixfold apertures and adds recursive detail',
      () async {
    final module = ModuleRegistry().byId('tortoise_toroidal_fractal');
    final baseParams = module.defaultPreset.params;
    final oneGeneration = await _renderModuleAtTime(
      module,
      0,
      params: <String, Object>{...baseParams, 'iterations': 1.0},
    );
    final threeGenerations = await _renderModuleAtTime(
      module,
      0,
      params: <String, Object>{...baseParams, 'iterations': 3.0},
    );

    // The dark component oracle counts the carrier aperture plus at least six
    // first-generation torus apertures. A collapsed/four-handle geometry fails.
    expect(_countEnclosedDarkComponents(oneGeneration), greaterThanOrEqualTo(7));

    var differingPixels = 0;
    for (var offset = 0; offset < oneGeneration.length; offset += 4) {
      if (oneGeneration[offset] != threeGenerations[offset] ||
          oneGeneration[offset + 1] != threeGenerations[offset + 1] ||
          oneGeneration[offset + 2] != threeGenerations[offset + 2]) {
        differingPixels++;
      }
    }
    expect(differingPixels, greaterThan(150));
  });

  test('every registered module has a reviewed animation capability', () {
    final expected = (jsonDecode(
      File('test/fixtures/animation_capability_inventory.json')
          .readAsStringSync(),
    ) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final actual = ModuleRegistry()
        .modules
        .map(
          (module) => <String, String>{
            'id': module.id,
            'shaderAsset': module.shaderAsset,
            'capability': module.animationCapability.name,
          },
        )
        .toList()
      ..sort((a, b) => a['id']!.compareTo(b['id']!));

    expect(
      actual,
      expected,
      reason: 'Every registry addition, shader reassignment, or capability '
          'change requires an explicit animation review and inventory update.',
    );
  });
}
