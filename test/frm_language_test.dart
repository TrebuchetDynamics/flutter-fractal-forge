import 'package:flutter_fractals/features/formulas/frm/complex.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_ast.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_engine.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_parser.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

/// Evaluates a single FRM expression with the given variable bindings by
/// wrapping it in a throwaway formula and running its init section.
Complex evalExpr(String expr, [Map<String, Complex> vars = const {}]) {
  final file = FrmParser('T {\n  out = $expr\n:\n  out = out\n}\n').parseFile();
  final ctx = FrmEvalContext(vars: {...vars});
  for (final stmt in file.formulas.single.init) {
    stmt.run(ctx);
  }
  return ctx.vars['out']!;
}

void main() {
  const z = Complex(2, 3);

  group('power operator', () {
    test('z^2 equals z*z exactly', () {
      expect(evalExpr('z^2', {'z': z}), evalExpr('z*z', {'z': z}));
      expect(evalExpr('z^2', {'z': z}), const Complex(-5, 12));
    });

    test('z^3 equals z*z*z', () {
      expect(evalExpr('z^3', {'z': z}), evalExpr('z*z*z', {'z': z}));
    });

    test('is right-associative: 2^3^2 == 2^(3^2) == 512', () {
      expect(evalExpr('2^3^2'), const Complex(512, 0));
    });

    test('unary minus binds looser than power: -z^2 == -(z^2)', () {
      // z = (0,2) => z^2 = (-4,0) => -(z^2) = (4,0)
      expect(evalExpr('-z^2', {'z': const Complex(0, 2)}), const Complex(4, 0));
    });
  });

  group('functions', () {
    test('sqr/conj/flip/real/imag', () {
      expect(evalExpr('sqr(z)', {'z': z}), evalExpr('z*z', {'z': z}));
      expect(evalExpr('conj(z)', {'z': z}), const Complex(2, -3));
      expect(evalExpr('flip(z)', {'z': z}), const Complex(3, 2));
      expect(evalExpr('real(z)', {'z': z}), const Complex(2, 0));
      expect(evalExpr('imag(z)', {'z': z}), const Complex(3, 0));
    });

    test('cabs / cabs2', () {
      final w = const Complex(3, 4);
      expect(evalExpr('cabs(z)', {'z': w}), const Complex(5, 0));
      expect(evalExpr('cabs2(z)', {'z': w}), const Complex(25, 0));
    });

    test('exp(0) == 1 and exp(log(z)) ~= z', () {
      expect(evalExpr('exp((0,0))'), const Complex(1, 0));
      final r = evalExpr('exp(log(z))', {'z': z});
      expect(r.re, closeTo(z.re, 1e-9));
      expect(r.im, closeTo(z.im, 1e-9));
    });

    test('nested calls and args: conj(z) + sqr(c)', () {
      final c = const Complex(1, -1);
      final r = evalExpr('conj(z) + sqr(c)', {'z': z, 'c': c});
      // conj(z)=(2,-3); sqr(c)=(1,-1)^2=(0,-2); sum=(2,-5)
      expect(r, const Complex(2, -5));
    });

    test('unknown function throws', () {
      expect(() => evalExpr('nope(z)', {'z': z}), throwsA(isA<StateError>()));
    });
  });

  group('rendering with new syntax', () {
    test('Mandelbrot via z^2 matches native, pixel-for-pixel', () {
      final formula = FrmParser(
        'Mandelbrot {\n  z = (0,0)\n  c = pixel\n:\n  z = z^2 + c\n}\n',
      ).parseFile().formulas.single;
      final frm = frmAsCpuFormula(formula);
      final native = cpuFormulaForModuleId('mandelbrot');
      final juliaC = Vector2.zero();
      for (var iy = 0; iy < 16; iy++) {
        for (var ix = 0; ix < 20; ix++) {
          final x = -2.2 + ix * (3.0 / 19);
          final y = -1.4 + iy * (2.8 / 15);
          expect(frm(x, y, 150, 2.0, juliaC), native(x, y, 150, 2.0, juliaC),
              reason: 'mismatch at ($x, $y)');
        }
      }
    });
  });
}
