import 'package:flutter_fractals/features/formulas/frm/frm_engine.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_parser.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('frmAsCpuFormula', () {
    const mandelbrotSrc = '''
Mandelbrot {
  z = (0,0)
  c = pixel
:
  z = z*z + c
}
''';

    test('FRM Mandelbrot matches the native CPU Mandelbrot pixel-for-pixel',
        () {
      final formula = FrmParser(mandelbrotSrc).parseFile().formulas.single;
      final frm = frmAsCpuFormula(formula);
      final native = cpuFormulaForModuleId('mandelbrot');

      const iterations = 200;
      const bailout = 2.0;
      final juliaC = Vector2.zero();

      // Sweep a grid across the classic Mandelbrot window, covering interior,
      // boundary, and exterior points.
      for (var iy = 0; iy < 24; iy++) {
        for (var ix = 0; ix < 32; ix++) {
          final x = -2.2 + ix * (3.0 / 31);
          final y = -1.4 + iy * (2.8 / 23);
          final a = native(x, y, iterations, bailout, juliaC);
          final b = frm(x, y, iterations, bailout, juliaC);
          expect(b, a, reason: 'mismatch at ($x, $y): native=$a frm=$b');
        }
      }
    });

    test('a formula that never assigns z renders as interior', () {
      final formula = FrmParser('Empty {\n  a = pixel\n:\n  a = a*a\n}\n')
          .parseFile()
          .formulas
          .single;
      final frm = frmAsCpuFormula(formula);
      // No `z` => cannot escape => interior colour for every point.
      expect(frm(0.5, 0.5, 50, 2.0, Vector2.zero()), (46.0, 120.0, 220.0));
    });
  });

  group('renderFrmImageBytes', () {
    test('renders a buffer of the requested size with opaque alpha', () {
      final bytes = renderFrmImageBytes(const FrmRenderRequest(
        source: 'Mandelbrot {\n  z=(0,0)\n  c=pixel\n:\n  z=z*z+c\n}\n',
        panX: -0.5,
        panY: 0.0,
        zoom: 0.4,
        width: 24,
        height: 24,
        iterations: 80,
        bailout: 2.0,
      ));
      expect(bytes.length, 24 * 24 * 4);
      // Alpha channel is fully opaque everywhere.
      for (var i = 3; i < bytes.length; i += 4) {
        expect(bytes[i], 255);
      }
      // Not a uniformly black/empty render.
      final nonBlack = List.generate(24 * 24,
              (p) => bytes[p * 4] + bytes[p * 4 + 1] + bytes[p * 4 + 2])
          .where((s) => s > 0)
          .length;
      expect(nonBlack, greaterThan(0));
    });

    test('throws FormatException for an unknown formula name', () {
      expect(
        () => renderFrmImageBytes(const FrmRenderRequest(
          source: 'Mandelbrot {\n  z=(0,0)\n:\n  z=z*z\n}\n',
          formulaName: 'Nope',
          panX: 0,
          panY: 0,
          zoom: 1,
          width: 4,
          height: 4,
          iterations: 10,
          bailout: 2.0,
        )),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
