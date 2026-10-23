import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';

void main() {
  test('one inspired Milnor identity, finite orbit metadata, no CPU substitute',
      () {
    final matches =
        ModuleRegistry().modules.where((m) => m.id == 'milnor_brieskorn');
    expect(matches, hasLength(1));
    final module = matches.single;
    final metadata = FractalMathematics.forModule(module);
    expect(metadata.view, 'Parameter plane');
    expect(metadata.qualification, contains('not an exotic sphere'));
    expect(metadata.formula({}),
        'z(0) = 0; z(n+1) = z(n)^5 + z(n)^3 + 3*z(n)^2 + c; finite orbit of 0 only');
    expect(hasNativeCpuFormula(module.id), isFalse);
    expect(hasCuratedCpuFormula(module.id), isFalse);
    expect(() => cpuFormulaForModuleId(module.id), throwsUnsupportedError);
    expect(module.builtInPresets.length, greaterThanOrEqualTo(2));
  });
}
