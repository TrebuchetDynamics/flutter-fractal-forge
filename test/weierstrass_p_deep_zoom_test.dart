import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weierstrass_p reported deep zoom routes to native CPU formula', () {
    const policy = PrecisionLadderPolicy();

    expect(hasNativeCpuFormula('weierstrass_p'), isTrue);
    expect(
      policy
          .decide(
            moduleId: 'weierstrass_p',
            dimension: FractalDimension.twoD,
            zoom: 413329,
          )
          .renderPath,
      PrecisionLadderRenderPath.cpu,
    );
  });
}
