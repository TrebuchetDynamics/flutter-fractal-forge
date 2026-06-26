import 'package:flutter_fractals/features/renderer/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/policy/deep_zoom_precision_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weierstrass_p reported deep zoom routes to native CPU formula', () {
    const policy = DeepZoomPrecisionPolicy();

    expect(hasNativeCpuFormula('weierstrass_p'), isTrue);
    expect(
      policy.shouldUseCpuFallback(moduleId: 'weierstrass_p', zoom: 413329),
      isTrue,
    );
  });
}
