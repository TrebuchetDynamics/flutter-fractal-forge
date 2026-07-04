import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps reported cos(z)+c initial framing', () {
    final view = ModuleRegistry().byId('f0499_cos_z_c').defaultPreset.view;

    expect(view.pan.x, closeTo(0.14142544567584991, 1e-12));
    expect(view.pan.y, closeTo(-0.3412726819515228, 1e-12));
    expect(view.zoom, closeTo(0.2, 1e-12));
  });

  test('keeps reported Taylor initial framing', () {
    final module = ModuleRegistry().byId('taylor');
    final view = module.defaultPreset.view;

    expect(module.defaultPreset.params['iterations'], 181);
    expect(view.pan.x, closeTo(-1.9122413396835327, 1e-12));
    expect(view.pan.y, closeTo(-0.37471362948417664, 1e-12));
    expect(view.zoom, closeTo(0.2, 1e-12));
  });

  test('keeps reported Sprott N initial framing', () {
    final module = ModuleRegistry().byId('sprott_n');
    final view = module.defaultPreset.view;

    expect(module.defaultPreset.params['iterations'], 133);
    expect(module.defaultPreset.params['bailout'], 4.9);
    expect(view.pan.x, closeTo(-0.11033250391483307, 1e-12));
    expect(view.pan.y, closeTo(-1.1267447471618652, 1e-12));
    expect(view.zoom, closeTo(0.2, 1e-12));
  });
}
