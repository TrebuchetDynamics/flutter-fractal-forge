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

    test('skips modules without a reference oracle', () {
      final result = RenderMathOracle.evaluate('barnsley_fern');

      expect(result.verdict, 'skipped');
      expect(result.reason, contains('no reference oracle'));
    });
  });
}
