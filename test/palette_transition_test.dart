import 'package:flutter_fractals/features/renderer/palette_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps target palette out of app state while returning render lerp', () {
    final transition = PaletteTransition();
    final start = DateTime(2026);

    expect(
      transition.valueFor(
        target: 0,
        now: start,
        min: 0,
        max: 63,
        animate: true,
      ),
      0,
    );

    transition.valueFor(
      target: 1,
      now: start,
      min: 0,
      max: 63,
      animate: true,
    );
    final mid = transition.valueFor(
      target: 1,
      now: start.add(
        Duration(milliseconds: PaletteTransition.duration.inMilliseconds ~/ 2),
      ),
      min: 0,
      max: 63,
      animate: true,
    );

    expect(mid, inExclusiveRange(0, 1));
    expect(
      transition.valueFor(
        target: 1,
        now: start.add(PaletteTransition.duration),
        min: 0,
        max: 63,
        animate: true,
      ),
      1,
    );
  });

  test('wraps the last palette into the first for sampler blending', () {
    final transition = PaletteTransition();
    final start = DateTime(2026);

    transition.valueFor(
      target: 63,
      now: start,
      min: 0,
      max: 63,
      animate: true,
    );
    transition.valueFor(
      target: 0,
      now: start,
      min: 0,
      max: 63,
      animate: true,
    );
    final mid = transition.valueFor(
      target: 0,
      now: start.add(
        Duration(milliseconds: PaletteTransition.duration.inMilliseconds ~/ 2),
      ),
      min: 0,
      max: 63,
      animate: true,
    );

    expect(mid, inExclusiveRange(63, 64));
  });
}
