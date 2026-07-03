import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/widgets/animation_effects.dart';

void main() {
  testWidgets('FractalMorphTransition does not scale the fractal view',
      (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FractalMorphTransition(
          currentFractalType: 'mandelbrot',
          child: SizedBox(width: 100, height: 100),
        ),
      ),
    );

    final transforms = tester.widgetList<Transform>(find.byType(Transform));
    for (final transform in transforms) {
      final m = transform.transform.storage;
      expect(m[0], closeTo(1.0, 0.001));
      expect(m[5], closeTo(1.0, 0.001));
    }
  });
}
