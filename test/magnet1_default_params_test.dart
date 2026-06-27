import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('magnet1 default preset uses reported useful initial params', () {
    final preset = ModuleRegistry().byId('magnet1').defaultPreset;

    expect(preset.params['iterations'], 158.0);
    expect(preset.params['bailout'], 8.0);
    expect(preset.view.pan.x, closeTo(0.7072526812553406, 1e-12));
    expect(preset.view.pan.y, closeTo(-0.21410192549228668, 1e-12));
    expect(preset.view.zoom, closeTo(0.2039256117342137, 1e-12));
  });
}
