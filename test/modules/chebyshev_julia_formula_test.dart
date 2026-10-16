import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Chebyshev Julia default, preset and thumbnail selection use c=-2', () {
    const id = 'f0166_chebyshev_julia';
    final entry =
        sharedJuliaCatalogEntries.singleWhere((entry) => entry.id == id);
    expect(entry.cReal, -2);
    expect(entry.cImag, 0);
    final registry = ModuleRegistry();
    final module = registry.byId(id);
    expect(
        module.parameters.singleWhere((p) => p.id == 'juliaCReal').defaultValue,
        -2);
    for (final preset in module.builtInPresets) {
      expect(preset.params['juliaCReal'], -2);
      expect(preset.params['juliaCImag'], 0);
    }
    // Runtime thumbnails select the module, changing only render budget/palette/view.
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    controller.selectModule(module, animate: false);
    expect(controller.params['juliaCReal'], -2);
    expect(controller.params['juliaCImag'], 0);
    controller.updateParam('juliaCReal', 2.0);
    expect(controller.params['juliaCReal'], 2.0);

    for (final x in [-1.0, -0.5, 0.0, 0.5, 1.0]) {
      final z = 2 * x;
      expect(z * z + entry.cReal, 2 * (2 * x * x - 1));
    }
  });
}
