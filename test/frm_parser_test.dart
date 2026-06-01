import 'package:flutter_fractals/features/formulas/frm/complex.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_ast.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FrmParser (subset)', () {
    test('parses multiple formulas with init/iter sections', () {
      const src = r'''
; comment
Mandelbrot {
  z = (0,0)
  c = pixel
:
  z = z*z + c
}

Julia {
  z = pixel
  c = (0.285, 0.01)
:
  z = z*z + c
}
''';

      final file = FrmParser(src).parseFile();
      expect(
          file.formulas.map((f) => f.name).toList(), ['Mandelbrot', 'Julia']);
      expect(file.formulas[0].init.length, 2);
      expect(file.formulas[0].iter.length, 1);
    });

    test('rejects adjacent assignments without a newline separator', () {
      const src = r'''
Test {
  z = (0,0) c = pixel
:
  z = z*z + c
}
''';

      expect(
        () => FrmParser(src).parseFile(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'Expected newline after statement',
          ),
        ),
      );
    });

    test('evaluates a simple iter statement', () {
      const src = r'''
Test {
  z = (0,0)
  c = (1,0)
:
  z = z*z + c
}
''';

      final formula = FrmParser(src).parseFile().formulas.single;
      final ctx = FrmEvalContext(vars: {
        'z': const Complex(0, 0),
        'c': const Complex(1, 0),
        'pixel': const Complex(0, 0),
      });

      for (final s in formula.init) {
        s.run(ctx);
      }
      // z=(0,0), c=(1,0)
      expect(ctx.vars['z']!.re, 0);
      expect(ctx.vars['c']!.re, 1);

      for (final s in formula.iter) {
        s.run(ctx);
      }
      // z = 0*0 + 1
      expect(ctx.vars['z']!.re, closeTo(1, 1e-12));
      expect(ctx.vars['z']!.im, closeTo(0, 1e-12));
    });
  });
}
