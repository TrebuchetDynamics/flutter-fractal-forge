import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FadeIn delay timer is cancelled when disposed early',
      (tester) async {
    // Regression: initState used Future.delayed, which cannot be cancelled;
    // disposing before the delay elapses left a pending timer and made the
    // widget untestable in timer-strict environments.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FadeIn(
          delay: const Duration(seconds: 2),
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    // If the delay timer leaked, flutter_test fails the test automatically
    // with "A Timer is still pending even after the widget tree was disposed".
  });

  testWidgets('FadeIn still fades in after the delay', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FadeIn(
          delay: const Duration(milliseconds: 50),
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );
    expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition))
            .opacity
            .value,
        closeTo(0.0, 0.01),
        reason: 'hidden before the delay elapses');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition))
            .opacity
            .value,
        closeTo(1.0, 0.01),
        reason: 'visible after the delay + animation');
  });
}
