import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Anchors the public copy in README.md (and the store listing) to the code.
///
/// If these fail, the registry or palette set changed size: update the
/// numbers in README.md and docs/store_listing/ together with this test.
void main() {
  test('README production fractal count matches the registry', () {
    final modules = ModuleRegistry().modules;
    final production = modules
        .where((m) => !m.shaderAsset.startsWith('shaders/diagnostic/'))
        .length;
    final diagnostics = modules.length - production;

    expect(production, 974,
        reason: 'README.md advertises 974 production fractals');
    expect(diagnostics, 7,
        reason: 'README.md says debug/test builds add 7 diagnostic modules');
  });

  test('README color scheme count is backed by the palette set', () {
    expect(CommonFractalParams.paletteCount, greaterThanOrEqualTo(60),
        reason: 'README.md advertises 60+ color schemes');
  });
}
