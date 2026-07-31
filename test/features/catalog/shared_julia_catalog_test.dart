import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  test('registers reviewed shared Julia formula identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedJuliaCatalogEntries, hasLength(51));
    for (final entry in sharedJuliaCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(
        module!.shaderAsset,
        'shaders/escape_time_family/core/julia_gpu.frag',
      );
      expect(module.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['juliaCReal'], entry.cReal);
      expect(module.defaultPreset.params['juliaCImag'], entry.cImag);
    }
  });

  test('YinFinite preserves the Fractint constant and viewport scale', () {
    final entry = sharedJuliaCatalogEntries.singleWhere(
      (entry) => entry.id == 'yinfinite_julia',
    );
    final module = ModuleRegistry().byId(entry.id);

    expect(entry.cReal, 0.252235);
    expect(entry.cImag, 0.000169836);
    expect(entry.name, 'YinFinite');
    expect(module.defaultPreset.params['iterations'], 320);
    expect(module.defaultPreset.params['colorScheme'], 50);
    expect(module.defaultPreset.view.pan.x, closeTo(-0.0033692, 1e-8));
    expect(module.defaultPreset.view.pan.y, closeTo(-0.00053805, 1e-8));
    expect(module.defaultPreset.view.zoom, closeTo(12.8344427091, 1e-10));
  });

  test('YinFinite default viewport has measurable escape structure', () async {
    final buffer = await renderCpuIterationBuffer(
      moduleId: 'yinfinite_julia',
      viewPan: Vector2(-0.0033692, -0.00053805),
      viewZoom: 12.8344427091,
      iterations: 320,
      bailout: 4,
      juliaC: Vector2(0.252235, 0.000169836),
      width: 64,
      height: 64,
    );

    expect(buffer, isNotNull);
    expect(buffer!.toSet().length, greaterThan(8));
    expect(buffer.where((iteration) => iteration == 320), isNotEmpty);
    expect(buffer.where((iteration) => iteration < 320), isNotEmpty);
  });

  test('caps shared Julia randomizable iterations for GPU stability', () {
    final iterations = ModuleRegistry()
        .byId('f0191_spring_julia')
        .parameters
        .singleWhere((param) => param.id == 'iterations');

    expect(iterations.max, 500.0);
  });
}
