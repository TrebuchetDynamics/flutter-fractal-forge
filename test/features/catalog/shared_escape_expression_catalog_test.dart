import 'package:flutter_fractals/core/modules/builders/shared_escape_expression_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers reviewed unique sine/cosine expression identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedEscapeExpressionCatalogEntries, hasLength(22));
    for (final entry in sharedEscapeExpressionCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['variant'], entry.variant);
      expect(module.parameters.any((p) => p.id == 'variant'), isTrue);
    }
  });

  test(
      'does not register duplicate expression-token aliases as counted modules',
      () {
    final ids = ModuleRegistry().modules.map((m) => m.id).toSet();

    expect(ids, isNot(contains('f0519_sin_z_c')));
    expect(ids, isNot(contains('f0521_sin_z_c')));
    expect(ids, isNot(contains('f0526_sin_z_z_c')));
    expect(ids, isNot(contains('f0520_cos_z_c')));
    expect(ids, isNot(contains('f0523_exp_z_z_c')));
    expect(ids, contains('f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin'));
  });

  test('keeps generic sine and cosine modules configured with variant zero',
      () {
    final registry = ModuleRegistry();

    expect(registry.byId('sine_mandelbrot').defaultPreset.params['variant'], 0);
    expect(
        registry.byId('cosine_mandelbrot').defaultPreset.params['variant'], 0);
  });

  test('keeps log-cos default framing on the reported useful region', () {
    final view = ModuleRegistry().byId('f0508_log_cos_z_c').defaultPreset.view;

    expect(view.pan.x, closeTo(-1.0138758420944214, 1e-12));
    expect(view.pan.y, closeTo(-0.30382946133613586, 1e-12));
    expect(view.zoom, closeTo(0.2588516917544482, 1e-12));
  });
}
