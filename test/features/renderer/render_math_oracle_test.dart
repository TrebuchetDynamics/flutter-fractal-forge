import 'package:flutter_fractals/features/renderer/diagnostics/render_math_oracle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RenderMathOracle', () {
    test('passes known Mandelbrot reference points', () {
      final result = RenderMathOracle.evaluate('mandelbrot');

      expect(result.verdict, 'pass');
      expect(result.checks, hasLength(2));
      expect(result.toJson(), containsPair('verdict', 'pass'));
    });

    test('passes known Julia far-escape reference point', () {
      final result = RenderMathOracle.evaluate('julia');

      expect(result.verdict, 'pass');
      expect(result.checks.single['name'], 'far point escapes');
    });

    test('passes exact Cantor Dust 3D product-set points', () {
      final result = RenderMathOracle.evaluate('cantor_dust_3d');

      expect(result.verdict, 'pass');
      expect(result.checks, hasLength(3));
      expect(
        result.checks.map((check) => check['actualContained']),
        [true, false, false],
      );
    });

    test('skips modules without a reference oracle', () {
      final result = RenderMathOracle.evaluate('barnsley_fern');

      expect(result.verdict, 'skipped');
      expect(result.reason, contains('no reference oracle'));
    });
  });
}
