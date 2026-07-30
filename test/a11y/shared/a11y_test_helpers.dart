import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a bounded number of frames after building an accessibility test widget.
///
/// Several app surfaces intentionally keep animations/tickers active, so
/// [WidgetTester.pumpAndSettle] can time out even after the accessibility tree
/// is ready. This helper advances the clock in bounded steps instead.
///
/// The budget has to outlast staggered entrances, not just the first frame. The
/// viewer's FAB column fades its buttons in on delays out to 490ms, and at the
/// previous 100ms budget the semantics tree held 1 of its 11 controls — so the
/// guideline tests on that screen were passing over ten of them. 1.4s clears
/// the longest entrance in the app (AppAnimations.slower at 500ms plus the
/// 240ms stagger) with room to spare.
Future<void> pumpAccessibilityTestFrames(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 14; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> expectMeetsAccessibilityGuideline(
  WidgetTester tester,
  AccessibilityGuideline guideline,
) async {
  final handle = tester.ensureSemantics();
  try {
    await pumpAccessibilityTestFrames(tester);
    await expectLater(tester, meetsGuideline(guideline));
  } finally {
    handle.dispose();
    await disposeAccessibilityTestWidget(tester);
  }
}

Future<void> disposeAccessibilityTestWidget(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpWidget(const SizedBox.shrink());
}
