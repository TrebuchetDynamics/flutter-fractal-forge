import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import '../helpers/render_test_shader.dart';

void main() {
  const coral2DAsset =
      'shaders/cellular_and_stochastic/brownian_tree_dla_gpu.frag';
  const coral3DAsset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/coral_growth_3d_gpu.frag';

  test('2D coral exposes an editable random seed at its shader slot', () {
    final module = ModuleRegistry().byId('brownian_tree_dla');
    final config = escapeTimeCatalog.singleWhere(
      (entry) => entry.id == 'brownian_tree_dla',
    );
    final seed =
        module.parameters.firstWhere((parameter) => parameter.id == 'seed');
    final shader = File(coral2DAsset).readAsStringSync();

    expect(config.name, 'Coral Growth (2D)');
    expect(config.defaultColorScheme, 3);
    expect(seed.min, 0);
    expect(seed.max, 9999);
    expect(seed.defaultValue, 37.0);
    expect(shader, contains('uniform float uBranchDensity; // 10'));
    expect(shader, contains('uniform float uJitter; // 11'));
    expect(shader, contains('uniform float uSeed; // 12'));
    expect(shader, contains('uSeed * 13.37'));
  });

  test('2D coral antialiasing edges stay ordered at high zoom', () {
    final shader = File(coral2DAsset).readAsStringSync();
    expect(shader, contains('float aaWidth = 0.012 / max(uZoom, 0.3);'));
    expect(
      shader,
      contains('smoothstep(min(0.002, aaWidth * 0.5), aaWidth, distanceValue)'),
    );

    for (final zoom in [0.0, 0.3, 0.85, 3.0, 6.0, 10.0, 1000000.0]) {
      final outer = 0.012 / (zoom < 0.3 ? 0.3 : zoom);
      final inner = (outer * 0.5).clamp(0.0, 0.002);
      expect(inner, lessThan(outer), reason: 'zoom=$zoom');
      final midpoint = (inner + outer) * 0.5;
      final t = ((midpoint - inner) / (outer - inner)).clamp(0.0, 1.0);
      expect(1.0 - t * t * (3.0 - 2.0 * t), closeTo(0.5, 1e-12));
      if (zoom <= 3.0) {
        expect(inner, 0.002, reason: 'preserve the original low-zoom ramp');
      }
    }
  });

  test('3D coral exposes a seed and compiles its ray-marched shader', () async {
    final module = ModuleRegistry().byId('coral_growth_3d');
    final seed =
        module.parameters.firstWhere((parameter) => parameter.id == 'seed');
    final shader = File(coral3DAsset).readAsStringSync();

    expect(seed.min, 0);
    expect(seed.max, 9999);
    expect(module.defaultPreset.params['seed'], 37);
    expect(module.defaultPreset.params['iterations'], 18);
    expect(module.defaultPreset.params['colorScheme'], 0);
    expect(module.defaultPreset.view.zoom, 1.35);
    expect(module.defaultPreset.view.rotation.x, 0.38);
    expect(module.defaultPreset.view.rotation.y, 0.45);
    expect(Raymarched3DUniformSlots.extraStart, 16);
    expect(shader, contains('uniform float uSeed; // 16'));
    expect(shader, contains('uSeed * 17.71'));
    expect(await ui.FragmentProgram.fromAsset(coral3DAsset), isNotNull);
  });

  for (final zoom in [0.85, 6.0, 10.0]) {
    test('2D coral renders structured, seed-dependent aggregates at zoom $zoom',
        () async {
      final program = await ui.FragmentProgram.fromAsset(coral2DAsset);
      final uniforms = <double>[
        0.0,
        64.0,
        64.0,
        0.0,
        0.0,
        zoom,
        96.0,
        4.0,
        3.0,
        0.0,
        1.15,
        0.9,
        37.0,
      ];
      final first = await renderTestShaderFrame(
        program: program,
        shaderAsset: coral2DAsset,
        width: 64,
        height: 64,
        uniforms: uniforms,
      );
      uniforms[12] = 91.0;
      final second = await renderTestShaderFrame(
        program: program,
        shaderAsset: coral2DAsset,
        width: 64,
        height: 64,
        uniforms: uniforms,
      );

      expect(_distinctColors(first), greaterThan(8));
      expect(_changedPixels(first, second), greaterThan(0));
      final bounds = _foregroundBounds(first, 64, 64);
      expect(bounds.width, greaterThan(22));
      expect(bounds.height, greaterThan(10));
    });
  }

  test('3D coral renders structured, seed-dependent aggregates', () async {
    final program = await ui.FragmentProgram.fromAsset(coral3DAsset);
    final uniforms = <double>[
      0.0,
      48.0,
      48.0,
      0.0,
      0.0,
      1.35,
      0.38,
      0.45,
      0.0,
      1.35,
      18.0,
      88.0,
      8.0,
      0.0,
      0.0,
      0.0,
      37.0,
    ];
    final first = await renderTestShaderFrame(
      program: program,
      shaderAsset: coral3DAsset,
      width: 48,
      height: 48,
      uniforms: uniforms,
    );
    uniforms[16] = 91.0;
    final second = await renderTestShaderFrame(
      program: program,
      shaderAsset: coral3DAsset,
      width: 48,
      height: 48,
      uniforms: uniforms,
    );

    expect(_distinctColors(first), greaterThan(8));
    expect(_changedPixels(first, second), greaterThan(0));
    final bounds = _foregroundBounds(first, 48, 48);
    expect(bounds.width, greaterThan(12));
    expect(bounds.height, greaterThan(14));
  });
}

int _distinctColors(List<int> rgba) => {
      for (var offset = 0; offset < rgba.length; offset += 4)
        (rgba[offset] << 24) |
            (rgba[offset + 1] << 16) |
            (rgba[offset + 2] << 8) |
            rgba[offset + 3],
    }.length;

int _changedPixels(List<int> first, List<int> second) {
  var changed = 0;
  for (var offset = 0; offset < first.length; offset += 4) {
    if (first[offset] != second[offset] ||
        first[offset + 1] != second[offset + 1] ||
        first[offset + 2] != second[offset + 2] ||
        first[offset + 3] != second[offset + 3]) {
      changed++;
    }
  }
  return changed;
}

ui.Rect _foregroundBounds(List<int> rgba, int width, int height) {
  var minX = width;
  var minY = height;
  var maxX = -1;
  var maxY = -1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final offset = (y * width + x) * 4;
      if (rgba[offset] < 50 && rgba[offset + 1] < 50 && rgba[offset + 2] < 50) {
        continue;
      }
      minX = minX < x ? minX : x;
      minY = minY < y ? minY : y;
      maxX = maxX > x ? maxX : x;
      maxY = maxY > y ? maxY : y;
    }
  }
  return maxX < 0
      ? ui.Rect.zero
      : ui.Rect.fromLTRB(minX.toDouble(), minY.toDouble(),
          (maxX + 1).toDouble(), (maxY + 1).toDouble());
}
