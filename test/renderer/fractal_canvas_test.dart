import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mirror toggle changes sector reflection independently of mode', () {
    expect(
      FractalCanvas.kaleidoscopeSectorScale(
        mirror: false,
        mode: 1,
        sector: 0,
      ),
      const Offset(1, 1),
    );
    expect(
      FractalCanvas.kaleidoscopeSectorScale(
        mirror: true,
        mode: 1,
        sector: 0,
      ),
      const Offset(-1, 1),
    );
  });
}
